module Data.Car exposing
    ( Model
    , decode
    , decodeList
    , encode
    , init
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , imgUrl : String
    , price : Float
    }


init : Model
init =
    { id = "", name = "", imgUrl = "", price = 0.0 }


encode : Model -> Encode.Value
encode car =
    Encode.object
        [ ( "id", Encode.string car.id )
        , ( "name", Encode.string car.name )
        , ( "imgUrl", Encode.string car.imgUrl )
        , ( "price", Encode.float car.price )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "imgUrl" Decode.string
        |> JDP.required "price" Decode.float


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "cars" (Decode.list decode)
