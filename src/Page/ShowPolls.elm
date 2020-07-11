module Page.ShowPolls exposing (Model, Msg(..), decode, update, view)

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


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchPolls constituency ->
            ( model, Cmd.none )

        PollsReceived polls ->
            ( model, Cmd.none )


decode : Decode.Decoder (List Poll.Model)
decode =
    Decode.field "polls" (Decode.list Poll.decode)
