module Page.ShowApproves exposing (Model, Msg(..), decode, default, update, view)

import Data.Approve as Approve
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchApproves
    | AddApprove
    | ShowDetail Approve.Model
    | ApprovesReceived (List Approve.Model)
    | Form Field
    | Save


type Field
    = Message String
    | Constituency String
    | Region String
    | Poll String
    | Agent String
    | CandidateType String
    | Msisdn String
    | PostedTs String
    | Status String


type alias Model =
    { approves : List Approve.Model
    , year : String
    , voteType : String
    , selectedApprove : Approve.Model
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ] [ renderApproveList model.approves ]
            , div [ class "col-md-4" ] [ renderDetails model.selectedApprove ]
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
            ( { model | selectedApprove = approve }, Cmd.none )

        ApprovesReceived approves ->
            ( { model | approves = approves }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddApprove ] [ Html.text "Add" ]
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


renderField : String -> String -> String -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []
        ]


renderDetails : Approve.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "message" model.message "eg.XXXX" Message
        , renderField "agent" model.agent.name "eg.Smith" Agent
        , renderField "region" model.region.name "eg.Ashanti" Region
        , renderField "constituency" model.constituency.name "e.g Bekwai" Constituency
        , renderField "poll station" model.poll.name "e.g XXX" Poll
        , renderField "type" model.candidateType "e.g 45.4" CandidateType
        , renderField "msisdn" model.msisdn "e.g +XXX XXXX" Msisdn
        , renderField "posted ts" model.postedTs "e.g 12.01.2020 16:54 32" PostedTs
        , renderField "status" model.status "e.g A/D" Status
        ]


decode : Decode.Decoder (List Approve.Model)
decode =
    Decode.field "approves" (Decode.list Approve.decode)


default : Model
default =
    { approves = [], year = "", voteType = "", selectedApprove = Approve.initApprove }
