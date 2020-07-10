module Data.Party exposing (Model, decode, encode, initParty)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , year : String
    , logo : String
    }


initParty : Model
initParty =
    { id = "", name = "", year = "", logo = "" }


encode : Model -> Encode.Value
encode party =
    Encode.object
        [ ( "name", Encode.string party.name )
        , ( "year", Encode.string party.year )
        , ( "logo", Encode.string party.logo )
        ]


decode : Decode.Decoder Model
decode =
    Decode.map4 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "year" Decode.string)
        (Decode.field "logo" Decode.string)
