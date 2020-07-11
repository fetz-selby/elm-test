module Page.ShowPolls exposing (Model, Msg(..), decode, view)

import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchPolls String
    | PollsReceived (List Poll.Model)


type alias Model =
    { polls : List Poll.Model
    , constituency : Constituency.Model
    }


view =
    div
        []
        []


decode : Decode.Decoder (List Poll.Model)
decode =
    Decode.field "polls" (Decode.list Poll.decode)
