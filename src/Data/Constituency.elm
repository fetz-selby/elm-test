module Data.Constituency exposing (Model, decode, encode, initConstituency)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , regionId : String
    }


initConstituency : Model
initConstituency =
    { id = "", name = "", regionId = "" }


encode : Model -> Encode.Value
encode constituency =
    Encode.object
        [ ( "name", Encode.string constituency.name )
        , ( "region_id", Encode.string constituency.regionId )
        ]


decode : Decode.Decoder Model
decode =
    Decode.map3 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "region_id" Decode.string)
