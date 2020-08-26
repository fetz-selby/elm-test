module Page.ShowApproves exposing (Model, Msg(..), decode, default, update, view)

import Data.Approve as Approve
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode
import Ports


type Msg
    = FetchApproves
    | ShowDetail Approve.Model
    | ApprovesReceived ApproveData
    | AddOne Approve.Model
    | UpdateOne Approve.Model
    | Form Field
    | OnEdit
    | Update
    | Reject
    | DetailMode ShowDetailMode
    | SearchList String


type Field
    = Message String
    | Id String
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
    , isLoading : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ if String.length model.searchWord > 0 then
            renderHeader <| String.fromInt <| List.length <| Approve.filter model.searchWord model.approves

          else
            renderHeader <| String.fromInt <| List.length <| model.approves
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
                        renderDetails model

                    Edit ->
                        renderEditableDetails model

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

        ShowDetail approve ->
            ( { model | showDetailMode = View, selectedApprove = approve }, Cmd.none )

        ApprovesReceived approveData ->
            ( { model | approves = approveData.approves }, Cmd.none )

        AddOne approve ->
            ( { model | approves = addToApproves approve model.approves }, Cmd.none )

        Form _ ->
            ( model, Cmd.none )

        Reject ->
            -- Show warning before proceeding
            ( { model | isLoading = True }, Ports.sendToJs (Ports.DeleteApprove <| model.selectedApprove.id) )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateApprove <| Approve.setIsApproved True <| model.selectedApprove) )

        UpdateOne approve ->
            ( { model
                | isLoading = False
                , approves = Approve.remove approve model.approves
                , showDetailMode = View
              }
            , Cmd.none
            )


renderHeader : String -> Html.Html Msg
renderHeader result =
    div [ class "row spacing" ]
        [ div [ class "col-md-7" ]
            [ input [ class "search-input", placeholder "Type to search", onInput SearchList ] []
            ]
        , div [ class "col-md-2 result" ]
            [ Html.text result ]
        , div [ class "col-md-3" ]
            []
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


renderDetails : Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Reject ]
            [ renderField "id" model.selectedApprove.id "eg. 123" False Id
            , renderField "message" model.selectedApprove.message "eg.XXXX" False Message
            , renderField "agent" model.selectedApprove.agent.name "eg.Smith" False Agent
            , renderField "constituency" model.selectedApprove.constituency.name "e.g Bekwai" False Constituency
            , renderField "poll station" model.selectedApprove.poll.name "e.g XXX" False Poll
            , renderField "type" model.selectedApprove.candidateType "e.g M/P" False CandidateType
            , renderField "msisdn" model.selectedApprove.msisdn "e.g +XXX XXXX" False Msisdn
            , renderField "posted ts" model.selectedApprove.postedTs "e.g 12.01.2020 16:54 32" False PostedTs
            , renderSubmitBtn model.isLoading (Approve.isValid model.selectedApprove) "Reject" "btn btn-danger" True
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "id" model.selectedApprove.id "eg. 123" False Id
        , renderField "message" model.selectedApprove.message "eg.XXXX" False Message
        , renderField "agent" model.selectedApprove.agent.name "eg.Smith" False Agent
        , renderField "constituency" model.selectedApprove.constituency.name "e.g Bekwai" False Constituency
        , renderField "poll station" model.selectedApprove.poll.name "e.g XXX" False Poll
        , renderField "type" model.selectedApprove.candidateType "e.g M/P" False CandidateType
        , renderField "msisdn" model.selectedApprove.msisdn "e.g +XXX XXXX" False Msisdn
        , renderField "posted ts" model.selectedApprove.postedTs "e.g 12.01.2020 16:54 32" False PostedTs
        , renderSubmitBtn model.isLoading (Approve.isValid model.selectedApprove) "Approve" "btn btn-danger" True
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
    , isLoading = False
    }
