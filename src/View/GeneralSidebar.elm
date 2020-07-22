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
    { name : String
    , title : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ menu "Regions" Regions
        , menu "Constituency" Constituencies
        , menu "Candidates" Candidates
        , menu "Polls" Polls
        , menu "Approve" Approve
        , menu "Summary" Summary
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Regions ->
            ( model, Cmd.none )

        Constituencies ->
            ( model, Cmd.none )

        Candidates ->
            ( model, Cmd.none )

        Parties ->
            ( model, Cmd.none )

        Polls ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


menu : String -> Msg -> Html.Html Msg
menu label event =
    div
        [ onClick event ]
        [ text label
        ]


default : Model
default =
    { name = "", title = "" }
