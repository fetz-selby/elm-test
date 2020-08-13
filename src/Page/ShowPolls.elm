module Page.ShowPolls exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchPolls String
    | AddPoll
    | ShowDetail Poll.Model
    | PollsReceived PollData
    | AddOne Poll.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Constituency String
    | TotalVoters String
    | RejectedVotes String
    | ValidVotes String


type ShowDetailMode
    = View
    | Edit
    | New


type alias PollData =
    { polls : List Poll.Model
    , constituencies : List Constituency.Model
    }


type alias Model =
    { polls : List Poll.Model
    , constituencies : List Constituency.Model
    , searchWord : String
    , year : String
    , selectedPoll : Poll.Model
    , showDetailMode : ShowDetailMode
    }


initShowCandidateModel : Model
initShowCandidateModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchPolls pollId ->
            ( model, Cmd.none )

        AddPoll ->
            ( { model | showDetailMode = New, selectedPoll = Poll.initPoll }, Cmd.none )

        ShowDetail poll ->
            ( { model | showDetailMode = View, selectedPoll = poll }, Cmd.none )

        PollsReceived pollData ->
            ( { model
                | polls = pollData.polls
                , constituencies = pollData.constituencies
              }
            , Cmd.none
            )

        AddOne poll ->
            ( { model | polls = addToPolls poll model.polls }, Cmd.none )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedPoll = Poll.setName name model.selectedPoll }, Cmd.none )

                Constituency constituencyId ->
                    ( { model | selectedPoll = Poll.setConstituency constituencyId model.selectedPoll }, Cmd.none )

                TotalVoters totalVotes ->
                    ( { model | selectedPoll = Poll.setTotalVotes totalVotes model.selectedPoll }, Cmd.none )

                RejectedVotes rejectedVotes ->
                    ( { model | selectedPoll = Poll.setRejectedVotes rejectedVotes model.selectedPoll }, Cmd.none )

                ValidVotes validVotes ->
                    ( { model | selectedPoll = Poll.setValidVotes validVotes model.selectedPoll }, Cmd.none )

        Save ->
            ( model, Cmd.batch [ Ports.sendToJs (Ports.SavePoll model.selectedPoll) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

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
                    renderPollList (Poll.filter model.searchWord model.polls)

                  else
                    renderPollList model.polls
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedPoll

                    Edit ->
                        renderEditableDetails model.selectedPoll

                    New ->
                        renderNewDetails model model.selectedPoll
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
            [ button [ class "btn btn-primary new-button", onClick AddPoll ] [ Html.text "New" ]
            ]
        ]


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


renderPollList : List Poll.Model -> Html.Html Msg
renderPollList polls =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderPollHeader ]
        , tbody []
            (List.map renderPollItem polls)
        ]


renderPollHeader : Html.Html Msg
renderPollHeader =
    tr []
        [ th [] [ Html.text "Poll Name" ]
        , th [] [ Html.text "Constituency" ]
        , th [] [ Html.text "Reject" ]
        , th [] [ Html.text "Valid" ]
        , th [] [ Html.text "Total" ]
        ]


renderPollItem : Poll.Model -> Html.Html Msg
renderPollItem poll =
    tr [ onClick (ShowDetail poll) ]
        [ td [] [ Html.text poll.name ]
        , td [] [ Html.text poll.constituency.name ]
        , td [] [ Html.text poll.rejectedVotes ]
        , td [] [ Html.text poll.validVotes ]
        , td [] [ Html.text poll.totalVoters ]
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


renderSubmitBtn : String -> String -> Bool -> Html.Html Msg
renderSubmitBtn label className isCustom =
    div [ class "form-group" ]
        [ button [ type_ "submit", classList [ ( className, True ), ( "btn-extra", isCustom ) ] ] [ Html.text label ]
        ]


renderDetails : Poll.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "name" model.name "eg. XXX" False Name
            , renderField "constituency" model.constituency.name "e.g Bantama" False Constituency
            , renderField "rejected" model.rejectedVotes "e.g 12" False RejectedVotes
            , renderField "valid" model.validVotes "e.g 1002" False ValidVotes
            , renderField "total" model.totalVoters "e.g 9088" False TotalVoters
            ]
        ]


renderEditableDetails : Poll.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "name" model.name "eg. XXX" True Name
        , renderField "constituency" model.constituency.name "eg. XXX" True Constituency
        , renderField "rejected" model.rejectedVotes "e.g 12" True RejectedVotes
        , renderField "valid" model.validVotes "e.g 1002" True ValidVotes
        , renderField "total" model.totalVoters "e.g 9088" True TotalVoters
        ]


renderNewDetails : Model -> Poll.Model -> Html.Html Msg
renderNewDetails model selectedPoll =
    form [ onSubmit Save ]
        [ renderField "name" selectedPoll.name "eg. XXX" True Name
        , renderConstituencies "constituency" Constituency model.constituencies
        , renderField "rejected" selectedPoll.rejectedVotes "e.g 12" True RejectedVotes
        , renderField "valid" selectedPoll.validVotes "e.g 1002" True ValidVotes
        , renderField "total" selectedPoll.totalVoters "e.g 9088" True TotalVoters
        , renderSubmitBtn "Save" "btn btn-danger" True
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedPoll = Poll.initPoll }


addToPolls : Poll.Model -> List Poll.Model -> List Poll.Model
addToPolls poll list =
    if Poll.isIdExist poll list then
        list

    else
        poll :: list


decode : Decode.Decoder PollData
decode =
    Decode.field "pollData" (Decode.map2 PollData Poll.decodeList Constituency.decodeList)


default : Model
default =
    { polls = []
    , constituencies = []
    , searchWord = ""
    , year = ""
    , selectedPoll = Poll.initPoll
    , showDetailMode = View
    }
