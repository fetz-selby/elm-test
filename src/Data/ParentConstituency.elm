module Data.ParentConstituency exposing (Model, decode, decodeList, encode, initParentConstituency)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    }


initParentConstituency : Model
initParentConstituency =
    { id = "", name = "" }


encode : Model -> Encode.Value
encode agent =
    Encode.object
        [ ( "name", Encode.string agent.name )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "parentConstituencies" (Decode.list decode)
