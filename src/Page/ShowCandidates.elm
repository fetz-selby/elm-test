module Page.ShowCandidates exposing (Msg(..), view)

import Data.Candidate as Candidate
import Html exposing (div)
import Html.Attributes exposing (..)


type Msg
    = FetchCandidates String


view : List Candidate.Model -> Html.Html Msg
view candidates =
    div
        []
        []
