module Page.ShowAgents exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Agent as Agent
import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, classList, disabled, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode
import Ports


type Msg
    = FetchAgents String
    | AddAgent
    | ShowDetail Agent.Model
    | AgentsReceived AgentData
    | AddOne Agent.Model
    | UpdateOne Agent.Model
    | Form Field
    | Save
    | Update
    | DetailMode ShowDetailMode
    | OnEdit
    | SearchList String


type Field
    = Name String
    | Constituency String
    | Poll String
    | Msisdn String
    | Pin String


type ShowDetailMode
    = View
    | Edit
    | New


type alias AgentData =
    { agents : List Agent.Model
    , constituencies : List Constituency.Model
    , polls : List Poll.Model
    }


type alias Model =
    { agents : List Agent.Model
    , constituencies : List Constituency.Model
    , polls : List Poll.Model
    , searchWord : String
    , year : String
    , selectedAgent : Agent.Model
    , showDetailMode : ShowDetailMode
    , isLoading : Bool
    }


initShowCandidateModel : Model
initShowCandidateModel =
    default


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchAgents agentId ->
            ( model, Cmd.none )

        AddAgent ->
            ( { model | showDetailMode = New, selectedAgent = Agent.initAgent }, Cmd.none )

        ShowDetail agent ->
            ( { model | showDetailMode = View, selectedAgent = agent }, Cmd.none )

        AgentsReceived agentData ->
            ( { model
                | agents = agentData.agents
                , constituencies = agentData.constituencies
                , polls = agentData.polls
              }
            , Cmd.none
            )

        AddOne agent ->
            ( { model
                | agents = addToAgents agent model.agents
                , showDetailMode = View
                , isLoading = False
              }
            , Cmd.none
            )

        Form field ->
            case field of
                Name name ->
                    ( { model | selectedAgent = Agent.setName name model.selectedAgent }, Cmd.none )

                Constituency constituencyId ->
                    ( { model | selectedAgent = Agent.setConstituency constituencyId model.selectedAgent }, Cmd.none )

                Poll pollId ->
                    ( { model | selectedAgent = Agent.setPoll pollId model.selectedAgent }, Cmd.none )

                Msisdn msisdn ->
                    ( { model | selectedAgent = Agent.setMsisdn msisdn model.selectedAgent }, Cmd.none )

                Pin pin ->
                    ( { model | selectedAgent = Agent.setPin pin model.selectedAgent }, Cmd.none )

        Save ->
            ( { model | isLoading = True }, Cmd.batch [ Ports.sendToJs (Ports.SaveAgent model.selectedAgent) ] )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnEdit ->
            ( { model | showDetailMode = Edit }, Cmd.none )

        SearchList val ->
            ( { model | searchWord = val }, Cmd.none )

        Update ->
            ( { model | isLoading = True }, Ports.sendToJs (Ports.UpdateAgent model.selectedAgent) )

        UpdateOne region ->
            ( { model
                | isLoading = False
                , agents = Agent.replace region model.agents
                , showDetailMode = View
              }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ if String.length model.searchWord > 0 then
                    renderAgentList (Agent.filter model.searchWord model.agents)

                  else
                    renderAgentList model.agents
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedAgent

                    Edit ->
                        renderEditableDetails model

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
            [ button [ class "btn btn-primary new-button", onClick AddAgent ] [ Html.text "New" ]
            ]
        ]


renderPolls : String -> (String -> Field) -> List Poll.Model -> Html.Html Msg
renderPolls fieldLabel field pollList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange (Form << field)
            ]
            (List.map pollItem pollList)
        ]


pollItem : Poll.Model -> Html.Html msg
pollItem item =
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


renderAgentList : List Agent.Model -> Html.Html Msg
renderAgentList agents =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderAgentHeader ]
        , tbody []
            (List.map renderAgentItem agents)
        ]


renderAgentHeader : Html.Html Msg
renderAgentHeader =
    tr []
        [ th [] [ Html.text "Name" ]
        , th [] [ Html.text "Msisdn" ]
        , th [] [ Html.text "Constituency" ]
        , th [] [ Html.text "Poll" ]
        ]


renderAgentItem : Agent.Model -> Html.Html Msg
renderAgentItem agent =
    tr [ onClick (ShowDetail agent) ]
        [ td [] [ Html.text agent.name ]
        , td [] [ Html.text agent.msisdn ]
        , td [] [ Html.text agent.constituency.name ]
        , td [] [ Html.text agent.poll.name ]
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


renderDetails : Agent.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "text" "name" model.name "eg. Smith" False Name
            , renderField "number" "msisdn" model.msisdn "e.g +491763500232450" False Msisdn
            , renderField "number" "pin" model.pin "e.g 0000" False Pin
            , renderField "text" "constituency" model.constituency.name "e.g P" False Constituency
            , renderField "text" "poll" model.poll.name "e.g Beach Road" False Poll
            ]
        ]


renderEditableDetails : Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Update ]
        [ renderField "text" "name" model.selectedAgent.name "eg. Smith" True Name
        , renderField "number" "msisdn" model.selectedAgent.msisdn "e.g +491763500232450" True Msisdn
        , renderField "number" "pin" model.selectedAgent.pin "e.g 0000" True Pin
        , renderConstituencies "constituency" Constituency model.constituencies
        , renderPolls "poll" Poll model.polls
        , renderSubmitBtn model.isLoading (Agent.isValid model.selectedAgent) "Save" "btn btn-danger" True
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "text" "name" model.selectedAgent.name "eg. Smith" True Name
        , renderField "number" "msisdn" model.selectedAgent.msisdn "eg. +491763500232450" True Msisdn
        , renderField "number" "pin" model.selectedAgent.pin "e.g 0000" True Pin
        , renderConstituencies "constituency" Constituency model.constituencies
        , renderPolls "poll" Poll model.polls
        , renderSubmitBtn model.isLoading (Agent.isValid model.selectedAgent) "Save" "btn btn-danger" True
        ]


showDetailState : ShowDetailMode -> Model -> Model
showDetailState mode model =
    case mode of
        View ->
            { model | showDetailMode = View }

        Edit ->
            { model | showDetailMode = Edit }

        New ->
            { model | showDetailMode = New, selectedAgent = Agent.initAgent }


addToAgents : Agent.Model -> List Agent.Model -> List Agent.Model
addToAgents agent list =
    if Agent.isIdExist agent list then
        list

    else
        agent :: list


decode : Decode.Decoder AgentData
decode =
    Decode.field "agentData" (Decode.map3 AgentData Agent.decodeList Constituency.decodeList Poll.decodeList)


default : Model
default =
    { agents = []
    , constituencies = []
    , polls = []
    , searchWord = ""
    , year = ""
    , selectedAgent = Agent.initAgent
    , showDetailMode = View
    , isLoading = False
    }
