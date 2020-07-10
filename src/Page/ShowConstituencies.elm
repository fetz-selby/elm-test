module Page.ShowConstituencies exposing (Model, Msg(..), view)

import Data.Constituency as Constituency
import Html exposing (div)
import Html.Attributes exposing (..)


type Msg
    = FetchConstituencies String


type alias Model =
    { constituencies : List Constituency.Model
    , region : String
    }


view =
    div
        []
        []
