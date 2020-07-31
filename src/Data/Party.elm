module Data.Party exposing (Model, decode, decodeList, encode, initParty)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , color : String
    , logoPath : String
    , orderQueue : Int
    }


initParty : Model
initParty =
    { id = "", name = "", color = "", logoPath = "", orderQueue = 0 }


encode : Model -> Encode.Value
encode party =
    Encode.object
        [ ( "name", Encode.string party.name )
        , ( "color", Encode.string party.color )
        , ( "logo_path", Encode.string party.logoPath )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "color" Decode.string
        |> JDP.required "logo_path" Decode.string
        |> JDP.required "order_queue" Decode.int


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "parties" (Decode.list decode)
