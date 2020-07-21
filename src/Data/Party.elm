module Data.Party exposing (Model, decode, encode, initParty)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , color : String
    , logoPath : String
    }


initParty : Model
initParty =
    { id = "", name = "", color = "", logoPath = "" }


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
