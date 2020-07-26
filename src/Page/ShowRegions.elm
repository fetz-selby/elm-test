module Page.ShowRegions exposing (Model, Msg(..), decode, default, update, view)

import Data.Region as Region
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchRegions
    | AddRegion
    | ShowDetail Region.Model
    | RegionsReceived (List Region.Model)


type alias Model =
    { regions : List Region.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderRegionList model.regions ]
            , div [ class "col-md-4" ] []
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
            ( model, Cmd.none )

        RegionsReceived regions ->
            ( { model | regions = regions }, Cmd.none )


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


decode : Decode.Decoder (List Region.Model)
decode =
    Decode.field "regions" (Decode.list Region.decode)


default : Model
default =
    { regions = [], year = "" }
