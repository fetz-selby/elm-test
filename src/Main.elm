module Main exposing (..)

import Browser as Browser
import Html as Html exposing (div)
import Model as AppModel
import Msg as AppMsg exposing (Msg(..))
import View as AppView


type Msg
    = AppMsg AppMsg.Msg
    | Error


type Page
    = App AppModel.Model
    | Err


type alias Model =
    { page : Page
    , user : String
    }



-- main =
--     Browser.sandbox {}


view : Model -> Html.Html Msg
view model =
    case model.page of
        App m ->
            AppView.view m
                |> Html.map AppMsg

        Err ->
            div [] []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppMsg m ->
            case m of
                ShowConstituencies consMsg ->
                    ( model, Cmd.none )

                ShowCandidates canMsg ->
                    ( model, Cmd.none )

                ShowPolls pollMsg ->
                    ( model, Cmd.none )

                ShowParties partyMsg ->
                    ( model, Cmd.none )

                IncomingMsgError err ->
                    ( model, Cmd.none )

        Error ->
            ( model, Cmd.none )
