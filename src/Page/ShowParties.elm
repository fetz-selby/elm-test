module Page.ShowParties exposing (Msg(..), decode, view)

import Data.Party as Party
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchParties String
    | PartiesReceived (List Party.Model)


view : List Party.Model -> Html.Html Msg
view parties =
    div
        []
        [ renderPartyList parties ]


renderPartyList : List Party.Model -> Html.Html Msg
renderPartyList parties =
    div []
        (List.map renderPartyItem parties)


renderPartyItem : Party.Model -> Html.Html Msg
renderPartyItem party =
    div []
        [ div [] [ Html.text party.name ]
        , div [] [ Html.text party.path ]
        , div [] [ Html.text party.logo ]
        ]


decode : Decode.Decoder (List Party.Model)
decode =
    Decode.field "parties" (Decode.list Party.decode)
