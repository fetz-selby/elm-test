module View.GeneralSidebar exposing (Model, Msg(..), default, update, view)

import Html exposing (div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Msg
    = Constituencies
    | Regions
    | Users
    | Agents
    | Candidates
    | Parties
    | Polls
    | Approve
    | RegionalSummary
    | NationalSummary


type alias Model =
    { current : Msg
    , title : String
    }


view : Model -> Html.Html Msg
view model =
    div
        [ class "row" ]
        [ menu "Regions" Regions
        , menu "Users" Users
        , menu "Agents" Agents
        , menu "Constituency" Constituencies
        , menu "Candidates" Candidates
        , menu "Parties" Parties
        , menu "Polls" Polls
        , menu "Approve" Approve
        , menu "Regional Summary" RegionalSummary
        , menu "National Summary" NationalSummary
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Regions ->
            ( { model | current = Regions }, Cmd.none )

        Agents ->
            ( { model | current = Agents }, Cmd.none )

        Users ->
            ( { model | current = Users }, Cmd.none )

        Constituencies ->
            ( { model | current = Constituencies }, Cmd.none )

        Candidates ->
            ( { model | current = Candidates }, Cmd.none )

        Parties ->
            ( { model | current = Parties }, Cmd.none )

        Polls ->
            ( { model | current = Polls }, Cmd.none )

        Approve ->
            ( { model | current = Approve }, Cmd.none )

        RegionalSummary ->
            ( { model | current = RegionalSummary }, Cmd.none )

        NationalSummary ->
            ( { model | current = NationalSummary }, Cmd.none )


menu : String -> Msg -> Html.Html Msg
menu label event =
    div
        [ class "col-md-12 sidebar-menu", onClick event ]
        [ text label
        ]


default : Model
default =
    { current = Regions, title = "" }
