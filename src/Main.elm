module Main exposing (main)

import Browser as Browser
import Html as Html exposing (div)
import Model as AppModel
import Msg as AppMsg exposing (Msg(..))
import Ports
import Update as AppUpdate
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



-- main : Program () Model Msg


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


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
        AppMsg appMsg ->
            case model.page of
                App appModel ->
                    let
                        ( _, upCmd ) =
                            AppUpdate.update appMsg appModel

                        cmd =
                            Cmd.map AppMsg upCmd
                    in
                    ( { model | page = App appModel }, cmd )

                Err ->
                    let
                        _ =
                            Debug.log "" "Error [Main-update-AppMsg]"
                    in
                    ( model, Cmd.none )

        Error ->
            let
                _ =
                    Debug.log "" "Error [Main-update]"
            in
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        App appModel ->
            Ports.msgForElm (AppMsg << AppMsg.decode appModel)

        Err ->
            Sub.none


init : String -> ( Model, Cmd Msg )
init _ =
    ( { page = App AppModel.default, user = "" }, Ports.sendToJs Ports.InitApp )
