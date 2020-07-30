module Data.Agent exposing (Model, decode, decodeList, encode, initAgent)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , msisdn : String
    }


initAgent : Model
initAgent =
    { id = "", name = "", msisdn = "" }


encode : Model -> Encode.Value
encode agent =
    Encode.object
        [ ( "name", Encode.string agent.name )
        , ( "msisdn", Encode.string agent.msisdn )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "msisdn" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "agents" (Decode.list decode)
