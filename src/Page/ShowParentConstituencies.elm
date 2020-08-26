module Page.ShowParentConstituencies exposing (Model, Msg(..), decode, default, initShowParentConstituencyModel, update, view)

import Data.ParentConstituency as ParentConstituency
import Data.Region as Region
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchParentConstituencies String
    | AddParentConstituency
    | ShowDetail ParentConstituency.Model
    | ParentConstituenciesReceived ParentConstituencyData
    | AddOne ParentConstituency.Model
    | UpdateOne ParentConstituency.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Id String
    | Region String


type ShowDetailMode
    = View
    | Edit
    | New


type alias ParentConstituencyData =
    { parentConstituencies : List ParentConstituency.Model
    }


type alias Model =
    { parentConstituencies : List ParentConstituency.Model
    , regions : List Region.Model
    , searchWord : String
    , selectedParentConstituency : ParentConstituency.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


initShowParentConstituencyModel : Model
initShowParentConstituencyModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchParentConstituencies _ ->
            ( model, Cmd.none )

        AddParentConstituency ->
            ( { model | showDetailMode = New, selectedParentConstituency = ParentConstituency.initParentConstituency }, Cmd.none )

        ShowDetail parentConstituency ->
            ( { model | showDetailMode = View, selectedParentConstituency = parentConstituency }, Cmd.none )

        ParentConstituenciesReceived parentConstituencyData ->
            ( { model
                | parentConstituencies = parentConstituencyData.parentConstituencies
              }
            , Cmd.none
            )

        AddOne parentConstituency ->
            ( { model
                | parentConstituencies = addToParentConstituencies parentConstituency model.parentConstituencies
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedParentConstituency = ParentConstituency.setName name model.selectedParentConstituency }, Cmd.none )

                Region regionId ->
                    ( { model | selectedParentConstituency = ParentConstituency.setRegionId regionId model.selectedParentConstituency }, Cmd.none )

                Id _ ->
                    ( model, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveParentConstituency model.selectedParentConstituency) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateParentConstituency model.selectedParentConstituency) )

        UpdateOne parent ->
            ( { model
                | isLoading = False
                , parentConstituencies = ParentConstituency.replace parent model.parentConstituencies
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| ParentConstituency.filter model.searchWord model.parentConstituencies

          else
            renderHeader <| String.fromInt <| List.length <| model.parentConstituencies
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderParentConstituencyList (ParentConstituency.filter model.searchWord model.parentConstituencies)

                  else
                    renderParentConstituencyList model.parentConstituencies
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedParentConstituency

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
            [ button [ class "btn btn-primary new-button", onClick AddParentConstituency ] [ Html.text "New" ]
            ]
        ]


renderParentConstituencyList : List ParentConstituency.Model -> Html.Html Msg
renderParentConstituencyList parentConstituencies =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderParentConstituenciesHeader ]
        , tbody []
            (List.map renderParentConstituencyItem parentConstituencies)
        ]


renderParentConstituenciesHeader : Html.Html Msg
renderParentConstituenciesHeader =
    tr []
        [ th [] [ Html.text "Name" ]
        , th [] [ Html.text "Region" ]
        ]


renderParentConstituencyItem : ParentConstituency.Model -> Html.Html Msg
renderParentConstituencyItem parentConstituency =
    tr [ onClick (ShowDetail parentConstituency) ]
        [ td [] [ Html.text parentConstituency.name ]
        , td [] [ Html.text parentConstituency.region.name ]
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


renderDetails : ParentConstituency.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "id" model.id "eg. 123" False Id
            , renderField "text" "name" model.name "eg. Bantama" False Name
            , renderField "text" "region" model.region.name "e.g Ashanti" False Region
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "id" model.selectedParentConstituency.id "eg. 123" False Id
        , renderField "text" "name" model.selectedParentConstituency.name "eg. Bantama" True Name
        , renderField "text" "region" model.selectedParentConstituency.region.name "e.g Ashanti" False Region
        , renderSubmitBtn model.isLoading (ParentConstituency.isValid model.selectedParentConstituency) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "name" model.selectedParentConstituency.name "eg. Bantama" True Name
        , renderSubmitBtn model.isLoading (ParentConstituency.isValid model.selectedParentConstituency) "Save" "btn btn-danger" True
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedParentConstituency = ParentConstituency.initParentConstituency }


addToParentConstituencies : ParentConstituency.Model -> List ParentConstituency.Model -> List ParentConstituency.Model
addToParentConstituencies parentConstituency list =
    if ParentConstituency.isIdExist parentConstituency list then
        list

    else
        parentConstituency :: list


decode : Decode.Decoder ParentConstituencyData
decode =
    Decode.field "parentConstituencyData" (Decode.map ParentConstituencyData ParentConstituency.decodeList)


default : Model
default =
    { parentConstituencies = []
    , regions = []
    , searchWord = ""
    , selectedParentConstituency = ParentConstituency.initParentConstituency
    , showDetailMode = View
    , isLoading = False
    }
