module Page.ShowCandidates exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Data.Party as Party
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchCandidates String
    | AddCandidate
    | ShowDetail Candidate.Model
    | CandidatesReceived CandidateData
    | AddOne Candidate.Model
    | UpdateOne Candidate.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Id String
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
    , isLoading : Bool
    }


initShowCandidateModel : Model
initShowCandidateModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchCandidates _ ->
            ( model, Cmd.none )

        AddCandidate ->
            ( { model | showDetailMode = New, selectedCandidate = Candidate.initCandidate }, Cmd.none )

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
            ( { model
                | candidates = addToCandidates candidate model.candidates
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedCandidate = Candidate.setName name model.selectedCandidate }, Cmd.none )

                CandidateType candidateType ->
                    ( { model | selectedCandidate = Candidate.setCandidateType candidateType model.selectedCandidate }, Cmd.none )

                Votes votes ->
                    ( { model | selectedCandidate = Candidate.setVotes votes model.selectedCandidate }, Cmd.none )

                AvatarPath avatarPath ->
                    ( { model | selectedCandidate = Candidate.setAvatarPath avatarPath model.selectedCandidate }, Cmd.none )

                Angle angle ->
                    ( { model | selectedCandidate = Candidate.setAngle angle model.selectedCandidate }, Cmd.none )

                Percentage percentage ->
                    ( { model | selectedCandidate = Candidate.setPercentage percentage model.selectedCandidate }, Cmd.none )

                BarRatio barRatio ->
                    ( { model | selectedCandidate = Candidate.setBarRatio barRatio model.selectedCandidate }, Cmd.none )

                Party partyId ->
                    ( { model | selectedCandidate = Candidate.setParty partyId model.selectedCandidate }, Cmd.none )

                Constituency constituencyId ->
                    ( { model | selectedCandidate = Candidate.setConstituency constituencyId model.selectedCandidate }, Cmd.none )

                Id _ ->
                    ( model, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveCandidate model.selectedCandidate) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateCandidate model.selectedCandidate) )

        UpdateOne candidate ->
            ( { model
                | isLoading = False
                , candidates = Candidate.replace candidate model.candidates
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| Candidate.filter model.searchWord model.candidates

          else
            renderHeader <| String.fromInt <| List.length <| model.candidates
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
                        renderEditableDetails model

                    New ->
                        renderNewDetails model
                ]
            ]
        ]


renderHeader : String -> Html.Html Msg
renderHeader result =
    div [ class "row spacing" ]
        [ div [ class "col-md-7" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-2 result" ]
            [ div [ class "row" ] [ Html.text result ]
            , div [ class "row label" ] [ Html.text "counts" ]
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddCandidate ] [ Html.text "New" ]
            ]
        ]


renderParties : String -> (String -> Field) -> List Party.Model -> Html.Html Msg
renderParties fieldLabel field partyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map partyItem partyList)
        ]


partyItem : Party.Model -> Html.Html msg
partyItem item =
    option [ value item.id ] [ Html.text item.name ]


renderConstituencies : String -> (String -> Field) -> List Constituency.Model -> Html.Html Msg
renderConstituencies fieldLabel field constituencyList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map constituencyItem constituencyList)
        ]


constituencyItem : Constituency.Model -> Html.Html msg
constituencyItem item =
    option [ value item.id ] [ Html.text item.name ]


renderGenericList : String -> (String -> Field) -> List { id : String, name : String } -> Html.Html Msg
renderGenericList fieldLabel field itemsList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map genericItem itemsList)
        ]


genericItem : { id : String, name : String } -> Html.Html msg
genericItem item =
    option [ value item.id ] [ Html.text item.name ]


getTypeList : List { id : String, name : String }
getTypeList =
    [ { id = "0", name = "Select" }, { id = "M", name = "Paliamentary" }, { id = "P", name = "Presidential" } ]


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


renderField : String -> String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField inputType fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ inputType, value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderSubmitBtn : Bool -> Bool -> String -> String -> Bool -> Html.Html Msg
renderSubmitBtn isLoading isValid label className isCustom =
    div [ class "form-group" ]
        [ if isLoading && isValid then
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text "Please wait ..." ]

          else if not isLoading && isValid then
            button
                [ type_ "submit"
                , classList [ ( className, True ), ( "btn-extra", isCustom ) ]
                ]
                [ Html.text label ]

          else
            button
                [ type_ "submit"
                , disabled True
                , classList [ ( "btn btn-extra", isCustom ), ( "btn-invalid", True ) ]
                ]
                [ Html.text label ]
        ]


renderDetails : Candidate.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "id" model.id "eg. 123" False Id
            , renderField "text" "name" model.name "eg. Smith" False Name
            , renderField "text" "constituency" model.constituency.name "e.g Bantama" False Constituency
            , renderField "text" "type" model.candidateType "e.g M/P" False CandidateType
            , renderField "number" "votes" model.votes "e.g 1002" False Votes
            , renderField "text" "party" model.party.name "e.g XXX" False Party
            , renderField "text" "avatar path" model.avatarPath "e.g XXX" False AvatarPath
            , renderField "text" "percentage" model.percentage "e.g 45.4" False Percentage
            , renderField "text" "angle" model.angle "e.g 180" False Angle
            , renderField "text" "bar" model.barRatio "e.g 234" False BarRatio
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "id" model.selectedCandidate.id "eg. 123" False Id
        , renderField "text" "name" model.selectedCandidate.name "eg. Smith" True Name
        , renderConstituencies "constituency" Constituency (Constituency.addIfNotExist Constituency.getFirstSelect model.constituencies)
        , renderParties "party" Party (Party.addIfNotExist Party.getFirstSelect model.parties)
        , renderGenericList "type" CandidateType getTypeList
        , renderField "number" "votes" model.selectedCandidate.votes "e.g 1002" True Votes
        , renderField "text" "avatar path" model.selectedCandidate.avatarPath "e.g XXX" True AvatarPath
        , renderField "text" "percentage" model.selectedCandidate.percentage "e.g 45.4" True Percentage
        , renderField "text" "angle" model.selectedCandidate.angle "e.g 180" True Angle
        , renderField "text" "bar" model.selectedCandidate.barRatio "e.g 234" True BarRatio
        , renderSubmitBtn model.isLoading (Candidate.isValid model.selectedCandidate) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "name" model.selectedCandidate.name "eg. Smith" True Name
        , renderConstituencies "constituency" Constituency (Constituency.addIfNotExist Constituency.getFirstSelect model.constituencies)
        , renderParties "party" Party (Party.addIfNotExist Party.getFirstSelect model.parties)
        , renderGenericList "type" CandidateType getTypeList
        , renderField "number" "votes" model.selectedCandidate.votes "e.g 1002" True Votes
        , renderField "text" "avatar path" model.selectedCandidate.avatarPath "e.g XXX" True AvatarPath
        , renderField "text" "percentage" model.selectedCandidate.percentage "e.g 45.4" True Percentage
        , renderField "text" "angle" model.selectedCandidate.angle "e.g 180" True Angle
        , renderField "text" "bar" model.selectedCandidate.barRatio "e.g 234" True BarRatio
        , renderSubmitBtn model.isLoading (Candidate.isValid model.selectedCandidate) "Save" "btn btn-danger" True
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
    if Candidate.isIdExist candidate list then
        list

    else
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
    , isLoading = False
    }
