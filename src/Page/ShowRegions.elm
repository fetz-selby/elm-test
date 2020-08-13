module Page.ShowRegions exposing (Model, Msg(..), decode, default, update, view)

import Data.Region as Region
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchRegions
    | AddRegion
    | ShowDetail Region.Model
    | RegionsReceived RegionData
    | AddOne Region.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String
    | OnDelete String
    | OnAdd


type Field
    = Name String
    | Seats String


type ShowDetailMode
    = View
    | Edit
    | New


type alias RegionData =
    { regions : List Region.Model }


type alias Model =
    { regions : List Region.Model
    , searchWord : String
    , year : String
    , selectedRegion : Region.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderRegionList (Region.filter model.searchWord model.regions)

                  else
                    renderRegionList model.regions
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedRegion

                    Edit ->
                        renderEditableDetails model.selectedRegion

                    New ->
                        renderNewDetails
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegions ->
            ( model, Cmd.none )

        AddRegion ->
            ( { model | showDetailMode = New, selectedRegion = Region.initRegion }, Cmd.none )

        ShowDetail region ->
            ( { model | showDetailMode = View, selectedRegion = region }, Cmd.none )

        RegionsReceived regionData ->
            ( { model | regions = regionData.regions }, Cmd.none )

        AddOne region ->
            ( { model | regions = addToRegions region model.regions }, Cmd.none )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedRegion = Region.modifyName name model.selectedRegion }, Cmd.none )

                Seats seat ->
                    ( { model | selectedRegion = Region.modifySeat seat model.selectedRegion }, Cmd.none )

        Save ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.SaveRegion model.selectedRegion) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        OnDelete id ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.DeleteRegion id) )

        OnAdd ->
            ( model, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddRegion ] [ Html.text "New" ]
            ]
        ]


renderRegionList : List Region.Model -> Html.Html Msg
renderRegionList regions =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderRegionHeader ]
        , tbody
            []
            (List.map renderRegionItem regions)
        ]


renderRegionHeader : Html.Html Msg
renderRegionHeader =
    tr []
        [ th [] [ Html.text "Region" ]
        , th [] [ Html.text "Seats" ]
        ]


renderRegionItem : Region.Model -> Html.Html Msg
renderRegionItem region =
    tr [ onClick (ShowDetail region) ]
        [ td [] [ Html.text region.name ]
        , td [] [ Html.text region.seats ]
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


renderDetails : Region.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form []
            [ renderField "region" model.name "eg.Ashanti" False Name
            , renderField "seat" model.seats "e.g 30" False Seats
            ]
        ]


renderEditableDetails : Region.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.name "eg.Ashanti" False Name
        , renderField "seat" model.seats "e.g 30" True Seats
        ]


renderNewDetails : Html.Html Msg
renderNewDetails =
    form [ onSubmit Save ]
        [ renderField "region" "" "eg.Ashanti" True Name
        , renderField "seat" "" "e.g 30" True Seats
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
            { model | showDetailMode = New, selectedRegion = Region.initRegion }


addToRegions : Region.Model -> List Region.Model -> List Region.Model
addToRegions region list =
    if Region.isIdExist region list then
        list

    else
        region :: list


decode : Decode.Decoder RegionData
decode =
    Decode.field "regionData" (Decode.map RegionData Region.decodeList)


default : Model
default =
    { regions = []
    , searchWord = ""
    , year = ""
    , selectedRegion = Region.initRegion
    , showDetailMode = View
    , isLoading = False
    }
