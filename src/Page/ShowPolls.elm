module Page.ShowPolls exposing (Model, Msg(..), view)

import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (div)
import Html.Attributes exposing (..)


type Msg
    = FetchPolls String


type alias Model =
    { polls : List Poll.Model
    , constituency : Constituency.Model
    }


view =
    div
        []
        []
