module Decoders exposing (..)

import Data exposing (..)
import Json.Decode exposing (Decoder, field, float, list, map, string, succeed)
import Json.Decode.Pipeline as JDP


decodeFeed : Decoder CarsData
decodeFeed =
    map CarsData
        (field "cars" (Json.Decode.list decodeCar))


decodeCar : Decoder Car
decodeCar =
    succeed Car
        |> JDP.required "id" string
        |> JDP.required "name" string
        |> JDP.required "imgUrl" string
        |> JDP.required "price" float
