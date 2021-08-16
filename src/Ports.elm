port module Ports exposing (OutgoingMsg(..), PortData, listenToJs, msgForElm, msgForJs, sendToJs, toPortData)

import Data exposing (..)
import Decoders exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type OutgoingMsg
    = FetchCars


port msgForJs : PortData -> Cmd msg


port msgForElm : (Encode.Value -> msg) -> Sub msg


listenToJs : (IncomingMsg -> Msg) -> Sub Msg
listenToJs tagger =
    msgForElm <|
        \dataToDecode ->
            case Decode.decodeValue incomingMsgDecoder dataToDecode of
                Ok incomingMsg ->
                    tagger incomingMsg

                Err err ->
                    IncomingDecoderError err


type alias PortData =
    { action : String
    , payload : Encode.Value
    }


incomingMsgDecoder : Decoder IncomingMsg
incomingMsgDecoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\action ->
                case action of
                    "CarsLoaded" ->
                        responseDecoder action decodeFeed
                            |> payloadDecoder
                            |> Decode.map InitLoad

                    _ ->
                        Decode.succeed <|
                            UnknownIncomingMessage
                                ("Decoder for incoming messages failed, because of unknown action name " ++ action)
            )


sendToJs : OutgoingMsg -> Cmd msg
sendToJs =
    toPortData >> msgForJs


toPortData : OutgoingMsg -> PortData
toPortData msg =
    case msg of
        FetchCars ->
            { action = "FetchCars", payload = Encode.null }


responseDecoder : String -> Decoder a -> Decoder (Result String a)
responseDecoder action decoder =
    Decode.oneOf
        [ decoder |> Decode.map Ok
        , Decode.field "error" Decode.string |> Decode.map Err
        ]


payloadDecoder : Decoder value -> Decoder value
payloadDecoder decoder =
    Decode.field "payload" decoder
