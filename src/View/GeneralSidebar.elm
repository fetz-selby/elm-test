module View.GeneralSidebar exposing (Model, Msg(..), default, update, view)

import Html exposing (div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type Msg
    = Constituencies
    | Regions
    | Candidates
    | Parties
    | Polls
    | Approve
    | Summary


type alias Model =
    { current : Msg
    , title : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ menu "Regions" Regions
        , menu "Constituency" Constituencies
        , menu "Candidates" Candidates
        , menu "Parties" Parties
        , menu "Polls" Polls
        , menu "Approve" Approve
        , menu "Summary" Summary
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Regions ->
            ( { model | current = Regions }, Cmd.none )

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

        Summary ->
            ( { model | current = Summary }, Cmd.none )


menu : String -> Msg -> Html.Html Msg
menu label event =
    div
        [ onClick event ]
        [ text label
        ]


default : Model
default =
    { current = Regions, title = "" }