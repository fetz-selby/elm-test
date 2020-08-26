module Page.ShowPolls exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
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
    | UpdateOne Poll.Model
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
    , isLoading : Bool
    }


initShowCandidateModel : Model
initShowCandidateModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchPolls _ ->
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
            ( { model
                | polls = addToPolls poll model.polls
                , isLoading = False
                , showDetailMode = View
              }
            , Cmd.none
            )

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

                Id _ ->
                    ( model, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SavePoll model.selectedPoll) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdatePoll model.selectedPoll) )

        UpdateOne poll ->
            ( { model
                | isLoading = False
                , polls = Poll.replace poll model.polls
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| Poll.filter model.searchWord model.polls

          else
            renderHeader <| String.fromInt <| List.length <| model.polls
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
            [ Html.text result ]
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


renderDetails : Poll.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "id" model.id "eg. 123" False Id
            , renderField "text" "name" model.name "eg. XXX" False Name
            , renderField "text" "constituency" model.constituency.name "e.g Bantama" False Constituency
            , renderField "number" "rejected" model.rejectedVotes "e.g 12" False RejectedVotes
            , renderField "number" "valid" model.validVotes "e.g 1002" False ValidVotes
            , renderField "number" "total" model.totalVoters "e.g 9088" False TotalVoters
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "id" model.selectedPoll.id "eg. 123" False Id
        , renderField "text" "name" model.selectedPoll.name "eg. XXX" True Name
        , renderConstituencies "constituency" Constituency (Constituency.addIfNotExist Constituency.getFirstSelect model.constituencies)
        , renderField "number" "rejected" model.selectedPoll.rejectedVotes "e.g 12" True RejectedVotes
        , renderField "number" "valid" model.selectedPoll.validVotes "e.g 1002" True ValidVotes
        , renderField "number" "total" model.selectedPoll.totalVoters "e.g 9088" True TotalVoters
        , renderSubmitBtn model.isLoading (Poll.isValid model.selectedPoll) "Update" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "name" model.selectedPoll.name "eg. XXX" True Name
        , renderConstituencies "constituency" Constituency (Constituency.addIfNotExist Constituency.getFirstSelect model.constituencies)
        , renderField "number" "rejected" model.selectedPoll.rejectedVotes "e.g 12" True RejectedVotes
        , renderField "number" "valid" model.selectedPoll.validVotes "e.g 1002" True ValidVotes
        , renderField "number" "total" model.selectedPoll.totalVoters "e.g 9088" True TotalVoters
        , renderSubmitBtn model.isLoading (Poll.isValid model.selectedPoll) "Save" "btn btn-danger" True
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
    , isLoading = False
    }
