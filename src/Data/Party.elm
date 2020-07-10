module Data.Party exposing (Model, decode, encode, initParty)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , path : String
    , logo : String
    }


initParty : Model
initParty =
    { id = "", name = "", path = "", logo = "" }


encode : Model -> Encode.Value
encode party =
    Encode.object
        [ ( "name", Encode.string party.name )
        , ( "path", Encode.string party.path )
        , ( "logo", Encode.string party.logo )
        ]


decode : Decode.Decoder Model
decode =
    Decode.map4 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "path" Decode.string)
        (Decode.field "logo" Decode.string)
