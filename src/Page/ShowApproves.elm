module Page.ShowApproves exposing (Model, Msg(..), decode, default, update, view)

import Data.Approve as Approve
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchApproves
    | AddApprove
    | ShowDetail Approve.Model
    | ApprovesReceived ApproveData
    | AddOne Approve.Model
    | Form Field
    | OnEdit
    | Update
    | Reject
    | DetailMode ShowDetailMode
    | SearchList String


type Field
    = Message String
    | Constituency String
    | Poll String
    | Agent String
    | CandidateType String
    | Msisdn String
    | PostedTs String


type ShowDetailMode
    = View
    | Edit
    | New


type alias ApproveData =
    { approves : List Approve.Model
    }


type alias Model =
    { approves : List Approve.Model
    , searchWord : String
    , year : String
    , voteType : String
    , selectedApprove : Approve.Model
    , showDetailMode : ShowDetailMode
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderApproveList (Approve.filter model.searchWord model.approves)

                  else
                    renderApproveList model.approves
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedApprove

                    Edit ->
                        renderEditableDetails model.selectedApprove

                    New ->
                        div [] []
                ]
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchApproves ->
            ( model, Cmd.none )

        AddApprove ->
            ( model, Cmd.none )

        ShowDetail approve ->
            ( { model | showDetailMode = View, selectedApprove = approve }, Cmd.none )

        ApprovesReceived approveData ->
            ( { model | approves = approveData.approves }, Cmd.none )

        AddOne approve ->
            ( { model | approves = addToApproves approve model.approves }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Update ->
            let
                updatedModel =
                    { model | selectedApprove = Approve.setIsApproved True model.selectedApprove }
            in
            ( updatedModel
            , Cmd.batch [ Ports.sendToJs (Ports.UpdateApprove updatedModel.selectedApprove) ]
            )

        Reject ->
            -- Show warning before proceeding
            ( model, Cmd.batch [ Ports.sendToJs (Ports.DeleteApprove model.selectedApprove.id) ] )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row spacing" ]
        [ div [ class "col-md-9" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-3" ]
            [ button [ class "btn btn-primary new-button", onClick AddApprove ] [ Html.text "New" ]
            ]
        ]


renderApproveList : List Approve.Model -> Html.Html Msg
renderApproveList approves =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderApproveHeader ]
        , tbody [] (List.map renderApproveItem approves)
        ]


renderApproveHeader : Html.Html Msg
renderApproveHeader =
    tr []
        [ th [] [ Html.text "Constituency Name" ]
        , th [] [ Html.text "Message" ]
        ]


renderApproveItem : Approve.Model -> Html.Html Msg
renderApproveItem approve =
    tr [ onClick (ShowDetail approve) ]
        [ td [] [ Html.text approve.constituency.name ]
        , td [] [ Html.text approve.message ]
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


renderDetails : Approve.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Reject ]
            [ renderField "message" model.message "eg.XXXX" False Message
            , renderField "agent" model.agent.name "eg.Smith" False Agent
            , renderField "constituency" model.constituency.name "e.g Bekwai" False Constituency
            , renderField "poll station" model.poll.name "e.g XXX" False Poll
            , renderField "type" model.candidateType "e.g M/P" False CandidateType
            , renderField "msisdn" model.msisdn "e.g +XXX XXXX" False Msisdn
            , renderField "posted ts" model.postedTs "e.g 12.01.2020 16:54 32" False PostedTs
            , renderSubmitBtn "Reject" "btn btn-danger" True
            ]
        ]


renderEditableDetails : Approve.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "message" model.message "eg.XXXX" False Message
        , renderField "agent" model.agent.name "eg.Smith" False Agent
        , renderField "constituency" model.constituency.name "e.g Bekwai" False Constituency
        , renderField "poll station" model.poll.name "e.g XXX" False Poll
        , renderField "type" model.candidateType "e.g M/P" False CandidateType
        , renderField "msisdn" model.msisdn "e.g +XXX XXXX" False Msisdn
        , renderField "posted ts" model.postedTs "e.g 12.01.2020 16:54 32" False PostedTs
        , renderSubmitBtn "Approve" "btn btn-danger" True
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedApprove = Approve.initApprove }


addToApproves : Approve.Model -> List Approve.Model -> List Approve.Model
addToApproves approve list =
    approve :: list


decode : Decode.Decoder ApproveData
decode =
    Decode.field "approveData" (Decode.map ApproveData Approve.decodeList)


default : Model
default =
    { approves = []
    , searchWord = ""
    , year = ""
    , voteType = ""
    , selectedApprove = Approve.initApprove
    , showDetailMode = View
    }
