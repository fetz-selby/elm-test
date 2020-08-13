module Page.ShowParentConstituencies exposing (Model, Msg(..), decode, default, initShowParentConstituencyModel, update, view)

import Data.ParentConstituency as ParentConstituency
import Data.Region as Region
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchParentConstituencies String
    | AddParentConstituency
    | ShowDetail ParentConstituency.Model
    | ParentConstituenciesReceived ParentConstituencyData
    | AddOne ParentConstituency.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Region String


type ShowDetailMode
    = View
    | Edit
    | New


type alias ParentConstituencyData =
    { parentConstituencies : List ParentConstituency.Model
    , regions : List Region.Model
    }


type alias Model =
    { parentConstituencies : List ParentConstituency.Model
    , regions : List Region.Model
    , searchWord : String
    , selectedParentConstituency : ParentConstituency.Model
    , showDetailMode : ShowDetailMode
    }


initShowParentConstituencyModel : Model
initShowParentConstituencyModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchParentConstituencies parentConstituencyId ->
            ( model, Cmd.none )

        AddParentConstituency ->
            ( { model | showDetailMode = New, selectedParentConstituency = ParentConstituency.initParentConstituency }, Cmd.none )

        ShowDetail parentConstituency ->
            ( { model | showDetailMode = View, selectedParentConstituency = parentConstituency }, Cmd.none )

        ParentConstituenciesReceived parentConstituencyData ->
            ( { model
                | parentConstituencies = parentConstituencyData.parentConstituencies
                , regions = parentConstituencyData.regions
              }
            , Cmd.none
            )

        AddOne parentConstituency ->
            ( { model | parentConstituencies = addToParentConstituencies parentConstituency model.parentConstituencies }, Cmd.none )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedParentConstituency = ParentConstituency.setName name model.selectedParentConstituency }, Cmd.none )

                Region regionId ->
                    ( { model | selectedParentConstituency = ParentConstituency.setRegionId regionId model.selectedParentConstituency }, Cmd.none )

        Save ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.SaveParentConstituency model.selectedParentConstituency) ] )

        Update ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.UpdateParentConstituency model.selectedParentConstituency) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

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
                    renderParentConstituencyList (ParentConstituency.filter model.searchWord model.parentConstituencies)

                  else
                    renderParentConstituencyList model.parentConstituencies
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedParentConstituency

                    Edit ->
                        renderEditableDetails model.selectedParentConstituency

                    New ->
                        renderNewDetails model model.selectedParentConstituency
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
            [ button [ class "btn btn-primary new-button", onClick AddParentConstituency ] [ Html.text "New" ]
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


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderSubmitBtn : String -> String -> Bool -> Html.Html Msg
renderSubmitBtn label className isCustom =
    div [ class "form-group" ]
        [ button [ type_ "submit", classList [ ( className, True ), ( "btn-extra", isCustom ) ] ] [ Html.text label ]
        ]


renderDetails : ParentConstituency.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "name" model.name "eg. Smith" False Name
            , renderField "region" model.region.name "e.g P" False Region
            ]
        ]


renderEditableDetails : ParentConstituency.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "name" model.name "eg. Smith" True Name
        , renderField "region" model.region.name "e.g P" True Region
        , renderSubmitBtn "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> ParentConstituency.Model -> Html.Html Msg
renderNewDetails model selectedParentConstituency =
    form [ onSubmit Save ]
        [ renderField "name" selectedParentConstituency.name "eg. Smith" True Name
        , renderRegions "region" Region model.regions
        , renderSubmitBtn "Save" "btn btn-danger" True
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
    parentConstituency :: list


decode : Decode.Decoder ParentConstituencyData
decode =
    Decode.field "parentConstituencyData" (Decode.map2 ParentConstituencyData ParentConstituency.decodeList Region.decodeList)


default : Model
default =
    { parentConstituencies = []
    , regions = []
    , searchWord = ""
    , selectedParentConstituency = ParentConstituency.initParentConstituency
    , showDetailMode = View
    }
