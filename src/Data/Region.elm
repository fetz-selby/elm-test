module Data.Region exposing (Model, decode, encode, initRegion)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , seats : Int
    }


initRegion : Model
initRegion =
    { id = "", name = "", seats = 0 }


encode : Model -> Encode.Value
encode region =
    Encode.object
        [ ( "name", Encode.string region.name )
        , ( "seats", Encode.int region.seats )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "seats" Decode.int
