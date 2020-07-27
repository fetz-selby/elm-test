module Page.ShowRegions exposing (Model, Msg(..), decode, default, update, view)

import Data.Region as Region
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchRegions
    | AddRegion
    | ShowDetail Region.Model
    | RegionsReceived (List Region.Model)
    | Form Field
    | Save


type Field
    = Name String
    | Seats String


type alias Model =
    { regions : List Region.Model
    , year : String
    , selectedRegion : Region.Model
    , isEditMode : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderRegionList model.regions ]
            , div [ class "col-md-4" ]
                [ if model.isEditMode then
                    renderEditableDetails model.selectedRegion

                  else
                    renderDetails model.selectedRegion
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegions ->
            ( model, Cmd.none )

        AddRegion ->
            ( model, Cmd.none )

        ShowDetail region ->
            ( { model | selectedRegion = region }, Cmd.none )

        RegionsReceived regions ->
            ( { model | regions = regions }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddRegion ] [ Html.text "Add" ]
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
        , td [] [ Html.text (String.fromInt region.seats) ]
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


renderDetails : Region.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.name "eg.Ashanti" False Name
        , renderField "seat" (String.fromInt model.seats) "e.g 300" False Seats
        ]


renderEditableDetails : Region.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "region" model.name "eg.Ashanti" False Name
        , renderField "seat" (String.fromInt model.seats) "e.g 300" True Seats
        ]


decode : Decode.Decoder (List Region.Model)
decode =
    Decode.field "regions" (Decode.list Region.decode)


default : Model
default =
    { regions = [], year = "", selectedRegion = Region.initRegion, isEditMode = False }
