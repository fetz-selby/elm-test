module Page.ShowUsers exposing (Model, Msg(..), decode, default, initShowUserModel, update, view)

import Data.Region as Region
import Data.User as User
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchUsers String
    | AddUser
    | ShowDetail User.Model
    | UsersReceived UserData
    | AddOne User.Model
    | UpdateOne User.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Id String
    | Email String
    | Password String
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
    , isLoading : Bool
    }


initShowUserModel : Model
initShowUserModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchUsers _ ->
            ( model, Cmd.none )

        AddUser ->
            ( { model | showDetailMode = New, selectedUser = User.initUser }, Cmd.none )

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
            ( { model
                | users = addToUsers user model.users
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedUser = User.setName name model.selectedUser }, Cmd.none )

                Email email ->
                    ( { model | selectedUser = User.setEmail email model.selectedUser }, Cmd.none )

                Msisdn msisdn ->
                    ( { model | selectedUser = User.setMsisdn msisdn model.selectedUser }, Cmd.none )

                Password password ->
                    ( { model | selectedUser = User.setPassword password model.selectedUser }, Cmd.none )

                Level level ->
                    ( { model | selectedUser = User.setLevel level model.selectedUser }, Cmd.none )

                Year year ->
                    ( { model | selectedUser = User.setYear year model.selectedUser }, Cmd.none )

                Region regionId ->
                    ( { model | selectedUser = User.setRegionId regionId model.selectedUser }, Cmd.none )

                Id _ ->
                    ( model, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveUser model.selectedUser) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateUser model.selectedUser) )

        UpdateOne user ->
            ( { model
                | isLoading = False
                , users = User.replace user model.users
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| User.filter model.searchWord model.users

          else
            renderHeader <| String.fromInt <| List.length <| model.users
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
                        renderEditableDetails model

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


renderHeader : String -> Html.Html Msg
renderHeader result =
    div [ class "row spacing" ]
        [ div [ class "col-md-7" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-2 result" ]
            [ Html.text result ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddUser ] [ Html.text "New" ]
            ]
        ]


renderRegions : String -> (String -> Field) -> List Region.Model -> Html.Html Msg
renderRegions fieldLabel field regionList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map regionItem regionList)
        ]


regionItem : Region.Model -> Html.Html msg
regionItem item =
    option [ value item.id ] [ Html.text item.name ]


renderGenericList : String -> String -> (String -> Field) -> List { id : String, name : String } -> Html.Html Msg
renderGenericList fieldLabel initialValue field itemsList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            , value initialValue
            ]
            (List.map genericItem itemsList)
        ]


genericItem : { id : String, name : String } -> Html.Html msg
genericItem item =
    option [ value item.id ] [ Html.text item.name ]


getLevelList : List { id : String, name : String }
getLevelList =
    [ { id = "0", name = "Select Level" }, { id = "U", name = "User" }, { id = "A", name = "Admin" } ]


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


renderField : String -> String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField inputType fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderSubmitBtn : Bool -> Bool -> String -> String -> Bool -> Html.Html Msg
renderSubmitBtn isLoading isValid label className isCustom =
    div [ class "form-group" ]
        [ if isLoading && isValid then
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text "Please wait ..." ]

          else if not isLoading && isValid then
            button
                [ type_ "submit"
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text label ]

          else
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( "btn btn-extra", isCustom ), ( "btn-invalid", True ) ]
                ]
                [ Html.text label ]
        ]


renderPasswordField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderPasswordField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "password", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "password", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : User.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form []
            [ renderField "text" "id" model.id "eg. 123" False Id
            , renderField "text" "name" model.name "eg. Smith" False Name
            , renderField "email" "email" model.email "eg. election@code.arbeitet.com" False Email
            , renderField "number" "msisdn" model.msisdn "e.g +491763500232450" False Msisdn
            , renderField "text" "level" model.level "e.g 0000" False Level
            , renderField "number" "year" model.year "e.g P" False Year
            , renderField "text" "region" model.region.name "e.g Ashanti Region" False Region
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "id" model.selectedUser.id "eg. 123" False Id
        , renderField "text" "name" model.selectedUser.name "eg. Smith" True Name
        , renderField "email" "email" model.selectedUser.email "eg. election@code.arbeitet.com" True Email
        , renderPasswordField "password" model.selectedUser.password "eg. password" True Password
        , renderField "number" "msisdn" model.selectedUser.msisdn "e.g +491763500232450" True Msisdn
        , renderGenericList "level" model.selectedUser.level Level getLevelList
        , renderField "number" "year" model.selectedUser.year "e.g 2020" True Year
        , renderRegions "region" Region (Region.addIfNotExist Region.getFirstSelect model.regions)
        , renderSubmitBtn model.isLoading (User.isValid model.selectedUser) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "name" model.selectedUser.name "eg. Smith" True Name
        , renderField "email" "email" model.selectedUser.email "eg. election@code.arbeitet.com" True Email
        , renderPasswordField "password" model.selectedUser.password "eg. password" True Password
        , renderField "number" "msisdn" model.selectedUser.msisdn "eg. +491763500232450" True Msisdn
        , renderGenericList "level" model.selectedUser.level Level getLevelList
        , renderField "number" "year" model.selectedUser.year "e.g 2020" True Year
        , renderRegions "region" Region (Region.addIfNotExist Region.getFirstSelect model.regions)
        , renderSubmitBtn model.isLoading (User.isValid model.selectedUser) "Save" "btn btn-danger" True
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
    if User.isIdExist user list then
        list

    else
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
    , isLoading = False
    }
