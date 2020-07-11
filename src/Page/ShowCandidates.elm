module Page.ShowCandidates exposing (Msg(..), decode, initShowCandidateModel, view)

import Data.Candidate as Candidate
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchCandidates String
    | CandidatesReceived (List Candidate.Model)


type alias Model =
    { candidates : List Candidate.Model
    , constituencyName : String
    , year : String
    }


initShowCandidateModel : Model
initShowCandidateModel =
    { candidates = [], constituencyName = "", year = "" }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderCandidateList model.candidates ]


renderCandidateList : List Candidate.Model -> Html.Html Msg
renderCandidateList candidates =
    div []
        (List.map renderCandidateItem candidates)


renderCandidateItem : Candidate.Model -> Html.Html Msg
renderCandidateItem candidate =
    div []
        [ div [] [ Html.text candidate.name ]
        , div [] [ Html.text (String.fromInt candidate.votes) ]
        , div [] [ Html.text candidate.party.name ]
        , div [] [ Html.text candidate.constituency.name ]
        , div [] [ Html.text candidate.year ]
        ]


decode : Decode.Decoder (List Candidate.Model)
decode =
    Decode.field "candidates" (Decode.list Candidate.decode)
