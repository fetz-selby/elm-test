module Page.ShowCandidates exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchCandidates String
    | AddCandidate
    | ShowDetail Candidate.Model
    | CandidatesReceived (List Candidate.Model)


type alias Model =
    { candidates : List Candidate.Model
    , constituency : Constituency.Model
    , year : String
    }


initShowCandidateModel : Model
initShowCandidateModel =
    { candidates = [], constituency = Constituency.default, year = "" }


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchCandidates constituencyId ->
            ( model, Cmd.none )

        AddCandidate ->
            ( model, Cmd.none )

        ShowDetail candidate ->
            ( model, Cmd.none )

        CandidatesReceived candidates ->
            ( { model | candidates = candidates }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderCandidateList model.candidates
                ]
            , div [ class "col-md-4" ] []
            ]
        ]


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddCandidate ] [ Html.text "Add" ]
            ]
        ]


renderCandidateList : List Candidate.Model -> Html.Html Msg
renderCandidateList candidates =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderNationalAnalysisHeader ]
        , tbody []
            (List.map renderCandidateItem candidates)
        ]


renderNationalAnalysisHeader : Html.Html Msg
renderNationalAnalysisHeader =
    tr []
        [ th [] [ Html.text "Candidate Name" ]
        , th [] [ Html.text "Votes" ]
        , th [] [ Html.text "Party" ]
        , th [] [ Html.text "Constituency" ]
        ]


renderCandidateItem : Candidate.Model -> Html.Html Msg
renderCandidateItem candidate =
    tr [ onClick (ShowDetail candidate) ]
        [ td [] [ Html.text candidate.name ]
        , td [] [ Html.text (String.fromInt candidate.votes) ]
        , td [] [ Html.text candidate.party.name ]
        , td [] [ Html.text candidate.constituency.name ]
        ]


decode : Decode.Decoder (List Candidate.Model)
decode =
    Decode.field "candidates" (Decode.list Candidate.decode)


default : Model
default =
    { candidates = [], constituency = Constituency.default, year = "" }
