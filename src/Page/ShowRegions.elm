module Page.ShowRegions exposing (Model, Msg(..), decode, default, update, view)

import Data.Region as Region
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchRegions
    | RegionsReceived (List Region.Model)


type alias Model =
    { regions : List Region.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderRegionList model.regions ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegions ->
            ( model, Cmd.none )

        RegionsReceived regions ->
            ( { model | regions = regions }, Cmd.none )


renderRegionList : List Region.Model -> Html.Html Msg
renderRegionList regions =
    div []
        (List.map renderRegionItem regions)


renderRegionItem : Region.Model -> Html.Html Msg
renderRegionItem region =
    div []
        [ div [] [ Html.text region.name ]
        , div [] [ Html.text (String.fromInt region.seats) ]
        ]


decode : Decode.Decoder (List Region.Model)
decode =
    Decode.field "regions" (Decode.list Region.decode)


default : Model
default =
    { regions = [], year = "" }
