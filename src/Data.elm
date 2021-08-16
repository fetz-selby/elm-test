module Data exposing (..)

import Json.Decode as Decode


type alias Car =
    { id : String, name : String, imgUrl : String, price : Float }


type alias CarsData =
    { cars : List Car }


type IncomingMsg
    = UnknownIncomingMessage String
    | InitLoad (Result String CarsData)


type Msg
    = OnModalClose
    | OnModalSubmit
    | OnRemove Car
    | PortMsgReceived IncomingMsg
    | IncomingDecoderError Decode.Error


emptyCar : Car
emptyCar =
    { id = "", name = "", imgUrl = "", price = 0.0 }
