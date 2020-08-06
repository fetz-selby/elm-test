module Page.ShowCandidates exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode


type Msg
    = FetchCandidates String
    | AddCandidate
    | ShowDetail Candidate.Model
    | CandidatesReceived CandidateData
    | AddOne Candidate.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnConstituencyChange String
    | OnPartyChange String
    | OnEdit
    | SearchList String


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


type ShowDetailMode
    = View
    | Edit
    | New


type alias CandidateData =
    { candidates : List Candidate.Model
    , constituencies : List Constituency.Model
    , parties : List Party.Model
    }


type alias Model =
    { candidates : List Candidate.Model
    , constituencies : List Constituency.Model
    , parties : List Party.Model
    , searchWord : String
    , year : String
    , selectedCandidate : Candidate.Model
    , showDetailMode : ShowDetailMode
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
            ( { model | showDetailMode = New }, Cmd.none )

        ShowDetail candidate ->
            ( { model | showDetailMode = View, selectedCandidate = candidate }, Cmd.none )

        CandidatesReceived candidateData ->
            ( { model
                | candidates = candidateData.candidates
                , constituencies = candidateData.constituencies
                , parties = candidateData.parties
              }
            , Cmd.none
            )

        AddOne candidate ->
            ( { model | candidates = addToCandidates candidate model.candidates }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnConstituencyChange val ->
            ( model, Cmd.none )

        OnPartyChange val ->
            ( model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderCandidateList (Candidate.filter model.searchWord model.candidates)

                  else
                    renderCandidateList model.candidates
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedCandidate

                    Edit ->
                        renderEditableDetails model.selectedCandidate

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddCandidate ] [ Html.text "New" ]
            ]
        ]


renderParties : String -> List Party.Model -> Html.Html Msg
renderParties fieldLabel partyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnPartyChange
            ]
            (List.map partyItem partyList)
        ]


partyItem : Party.Model -> Html.Html msg
partyItem item =
    option [ value item.id ] [ Html.text item.name ]


renderConstituencies : String -> List Constituency.Model -> Html.Html Msg
renderConstituencies fieldLabel constituencyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnConstituencyChange
            ]
            (List.map constituencyItem constituencyList)
        ]


constituencyItem : Constituency.Model -> Html.Html msg
constituencyItem item =
    option [ value item.id ] [ Html.text item.name ]


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
        , td [] [ Html.text candidate.votes ]
        , td [] [ Html.text candidate.party.name ]
        , td [] [ Html.text candidate.constituency.name ]
        ]


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : Candidate.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "name" model.name "eg. Smith" False Name
            , renderField "constituency" model.constituency.name "e.g P" False Constituency
            , renderField "type" model.candidateType "e.g P" False CandidateType
            , renderField "votes" model.votes "e.g 1002" False Votes
            , renderField "party" model.party.name "e.g XXX" False Party
            , renderField "avatar path" model.avatarPath "e.g XXX" False AvatarPath
            , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" False Percentage
            , renderField "angle" (String.fromFloat model.angle) "e.g 180" False Angle
            , renderField "bar" (String.fromFloat model.barRatio) "e.g 234" False BarRatio
            ]
        ]


renderEditableDetails : Candidate.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "name" model.name "eg. Smith" True Name
        , renderField "constituency" model.constituency.name "e.g P" True Constituency
        , renderField "type" model.candidateType "e.g P" True CandidateType
        , renderField "votes" model.votes "e.g 1002" True Votes
        , renderField "party" model.party.name "e.g XXX" True Party
        , renderField "avatar path" model.avatarPath "e.g XXX" True AvatarPath
        , renderField "percentage" (String.fromFloat model.percentage) "e.g 45.4" True Percentage
        , renderField "angle" (String.fromFloat model.angle) "e.g 180" True Angle
        , renderField "bar" (String.fromFloat model.barRatio) "e.g 234" True BarRatio
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "name" "" "eg. Smith" True Name
        , renderConstituencies "constituency" model.constituencies
        , renderParties "party" model.parties
        , renderField "type" "" "e.g P" True CandidateType
        , renderField "votes" "" "e.g 1002" True Votes
        , renderField "avatar path" "" "e.g XXX" True AvatarPath
        , renderField "percentage" "" "e.g 45.4" True Percentage
        , renderField "angle" "" "e.g 180" True Angle
        , renderField "bar" "" "e.g 234" True BarRatio
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedCandidate = Candidate.initCandidate }


addToCandidates : Candidate.Model -> List Candidate.Model -> List Candidate.Model
addToCandidates candidate list =
    candidate :: list


decode : Decode.Decoder CandidateData
decode =
    Decode.field "candidateData" (Decode.map3 CandidateData Candidate.decodeList Constituency.decodeList Party.decodeList)


default : Model
default =
    { candidates = []
    , constituencies = []
    , parties = []
    , searchWord = ""
    , year = ""
    , selectedCandidate = Candidate.initCandidate
    , showDetailMode = View
    }
