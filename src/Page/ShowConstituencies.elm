module Page.ShowConstituencies exposing (Model, Msg(..), decode, view)

import Data.Constituency as Constituency
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchConstituencies String
    | ConstituenciesReceived (List Constituency.Model)


type alias Model =
    { constituencies : List Constituency.Model
    , region : String
    }


view : List Constituency.Model -> Html.Html Msg
view constituencies =
    div
        []
        [ renderConstituencyList constituencies ]


renderConstituencyList : List Constituency.Model -> Html.Html Msg
renderConstituencyList constituencies =
    div []
        (List.map renderConstituencyItem constituencies)


renderConstituencyItem : Constituency.Model -> Html.Html Msg
renderConstituencyItem constituency =
    div []
        [ div [] [ Html.text constituency.name ]
        , div [] [ Html.text constituency.year ]
        ]


decode : Decode.Decoder (List Constituency.Model)
decode =
    Decode.field "constituencies" (Decode.list Constituency.decode)
