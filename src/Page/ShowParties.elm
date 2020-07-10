module Page.ShowParties exposing (Msg(..), view)

import Data.Party as Party
import Html exposing (div)
import Html.Attributes exposing (..)


type Msg
    = FetchParties String


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
