module Page.ShowAgents exposing (Model, Msg(..), decode, default, initShowCandidateModel, update, view)

import Data.Agent as Agent
import Data.Constituency as Constituency
import Data.Poll as Poll
import Html exposing (button, div, form, input, label, option, select, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onChange)
import Json.Decode as Decode


type Msg
    = FetchAgents String
    | AddAgent
    | ShowDetail Agent.Model
    | AgentsReceived AgentData
    | AddOne Agent.Model
    | Form Field
    | Save
    | DetailMode ShowDetailMode
    | OnConstituencyChange String
    | OnPollChange String
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
            ( { model | showDetailMode = New }, Cmd.none )

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
            ( { model | agents = addToAgents agent model.agents }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )

        DetailMode mode ->
            ( showDetailState mode model, Cmd.none )

        OnConstituencyChange val ->
            ( model, Cmd.none )

        OnPollChange val ->
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
                    renderAgentList (Agent.filter model.searchWord model.agents)

                  else
                    renderAgentList model.agents
                ]
            , div [ class "col-md-4" ]
                [ case model.showDetailMode of
                    View ->
                        renderDetails model.selectedAgent

                    Edit ->
                        renderEditableDetails model.selectedAgent

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


renderPolls : String -> List Poll.Model -> Html.Html Msg
renderPolls fieldLabel pollList =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , select
            [ class "form-control"
            , onChange OnPollChange
            ]
            (List.map pollItem pollList)
        ]


pollItem : Poll.Model -> Html.Html msg
pollItem item =
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


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : Agent.Model -> Html.Html Msg
renderDetails model =
    div []
        [ div [ class "col-md-12 spacing-bottom" ]
            [ div [ class "pull-right edit-style", onClick OnEdit ] [ Html.text "edit" ]
            ]
        , form [ onSubmit Save ]
            [ renderField "name" model.name "eg. Smith" False Name
            , renderField "msisdn" model.msisdn "e.g +491763500232450" False Msisdn
            , renderField "pin" model.pin "e.g 0000" False Pin
            , renderField "constituency" model.constituency.name "e.g P" False Constituency
            , renderField "poll" model.poll.name "e.g Beach Road" False Poll
            ]
        ]


renderEditableDetails : Agent.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "name" model.name "eg. Smith" True Name
        , renderField "msisdn" model.msisdn "e.g +491763500232450" True Msisdn
        , renderField "pin" model.pin "e.g 0000" True Pin
        , renderField "constituency" model.constituency.name "e.g P" True Constituency
        , renderField "poll" model.poll.name "e.g Beach Road" True Poll
        ]


renderNewDetails : Model -> Html.Html Msg
renderNewDetails model =
    form [ onSubmit Save ]
        [ renderField "name" "" "eg. Smith" True Name
        , renderField "msisdn" "" "eg. +491763500232450" True Msisdn
        , renderField "pin" "" "e.g 0000" True Pin
        , renderConstituencies "constituency" model.constituencies
        , renderPolls "poll" model.polls
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
    }
