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
        [ renderCandidateList candidates ]


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
