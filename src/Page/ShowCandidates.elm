module Page.ShowCandidates exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Candidate as Candidate
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchCandidates String
    | AddCandidate
    | ShowDetail Candidate.Model
    | CandidatesReceived (List Candidate.Model)
    | Form Field
    | Save


type Field
    = Name String
    | Constituency String
    | Party String
    | CandidateType String
    | Votes String
    | AvatarPath String
    | Angle String
    | Percentage String
    | BarRatio String


type alias Model =
    { candidates : List Candidate.Model

    -- , constituency : Constituency.Model
    , year : String
    , selectedCandidate : Candidate.Model
    }


initShowCandidateModel : Model
initShowCandidateModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchCandidates constituencyId ->
            ( model, Cmd.none )

        AddCandidate ->
            ( model, Cmd.none )

        ShowDetail candidate ->
            ( { model | selectedCandidate = candidate }, Cmd.none )

        CandidatesReceived candidates ->
            ( { model | candidates = candidates }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderCandidateList model.candidates
                ]
            , div [ class "col-md-4" ] [ renderDetails model.selectedCandidate ]
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


renderField : String -> String -> String -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []
        ]


renderDetails : Candidate.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "name" model.name "eg.Ashanti" Name
        , renderField "constituency" model.constituency.name "e.g P" Constituency
        , renderField "type" model.candidateType "e.g P" CandidateType
        , renderField "votes" (String.fromInt model.votes) "e.g 1002" Votes
        , renderField "party" model.party.name "e.g XXX" Party
        , renderField "avatar path" model.avatarPath "e.g XXX" AvatarPath
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" Angle
        , renderField "bar" (String.fromFloat model.barRatio) "e.g 234" BarRatio
        ]


decode : Decode.Decoder (List Candidate.Model)
decode =
    Decode.field "candidates" (Decode.list Candidate.decode)


default : Model
default =
    { candidates = [], year = "", selectedCandidate = Candidate.initCandidate }
