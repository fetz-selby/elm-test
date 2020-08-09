module Page.ShowUsers exposing (Model, Msg(..), decode, default, initShowUserModel, update, view)

import Data.Region as Region
import Data.User as User
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode


type Msg
    = FetchUsers String
    | AddUser
    | ShowDetail User.Model
    | UsersReceived UserData
    | AddOne User.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnRegionChange String
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Msisdn String
    | Level String
    | Year String
    | Region String


type ShowDetailMode
    = View
    | Edit
    | New


type alias UserData =
    { users : List User.Model
    , regions : List Region.Model
    }


type alias Model =
    { users : List User.Model
    , regions : List Region.Model
    , searchWord : String
    , year : String
    , selectedUser : User.Model
    , showDetailMode : ShowDetailMode
    }


initShowUserModel : Model
initShowUserModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchUsers userId ->
            ( model, Cmd.none )

        AddUser ->
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail user ->
            ( { model | showDetailMode = View, selectedUser = user }, Cmd.none )

        UsersReceived userData ->
            ( { model
                | users = userData.users
                , regions = userData.regions
              }
            , Cmd.none
            )

        AddOne user ->
            ( { model | users = addToUsers user model.users }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnRegionChange val ->
            ( model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderUserList (User.filter model.searchWord model.users)

                  else
                    renderUserList model.users
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedUser

                    Edit ->
                        renderEditableDetails model.selectedUser

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddUser ] [ Html.text "New" ]
            ]
        ]


renderRegions : String -> List Region.Model -> Html.Html Msg
renderRegions fieldLabel regionList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnRegionChange
            ]
            (List.map regionItem regionList)
        ]


regionItem : Region.Model -> Html.Html msg
regionItem item =
    option [ value item.id ] [ Html.text item.name ]


renderUserList : List User.Model -> Html.Html Msg
renderUserList users =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderUserHeader ]
        , tbody []
            (List.map renderUserItem users)
        ]


renderUserHeader : Html.Html Msg
renderUserHeader =
    tr []
        [ th [] [ Html.text "Name" ]
        , th [] [ Html.text "Msisdn" ]
        , th [] [ Html.text "Level" ]
        , th [] [ Html.text "Year" ]
        , th [] [ Html.text "Region" ]
        ]


renderUserItem : User.Model -> Html.Html Msg
renderUserItem user =
    tr [ onClick (ShowDetail user) ]
        [ td [] [ Html.text user.name ]
        , td [] [ Html.text user.msisdn ]
        , td [] [ Html.text user.level ]
        , td [] [ Html.text user.year ]
        , td [] [ Html.text user.region.name ]
        ]


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : User.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "name" model.name "eg. Smith" False Name
            , renderField "msisdn" model.msisdn "e.g +491763500232450" False Msisdn
            , renderField "level" model.level "e.g 0000" False Level
            , renderField "year" model.year "e.g P" False Year
            , renderField "region" model.region.name "e.g Ashanti Region" False Region
            ]
        ]


renderEditableDetails : User.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "name" model.name "eg. Smith" True Name
        , renderField "msisdn" model.msisdn "e.g +491763500232450" True Msisdn
        , renderField "level" model.level "e.g 0000" True Level
        , renderField "year" model.year "e.g P" True Year
        , renderField "region" model.region.name "e.g Beach Road" True Region
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "name" "" "eg. Smith" True Name
        , renderField "msisdn" "" "eg. +491763500232450" True Msisdn
        , renderField "level" "" "e.g 0000" True Level
        , renderField "year" "" "e.g 0000" True Year
        , renderRegions "region" model.regions
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedUser = User.initUser }


addToUsers : User.Model -> List User.Model -> List User.Model
addToUsers user list =
    user :: list


decode : Decode.Decoder UserData
decode =
    Decode.field "userData" (Decode.map2 UserData User.decodeList Region.decodeList)


default : Model
default =
    { users = []
    , regions = []
    , searchWord = ""
    , year = ""
    , selectedUser = User.initUser
    , showDetailMode = View
    }
