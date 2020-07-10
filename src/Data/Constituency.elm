module Data.Constituency exposing (Model, decode, encode, initConstituency)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , regionId : String
    , year : String
    }


initConstituency : Model
initConstituency =
    { id = "", name = "", regionId = "", year = "" }


encode : Model -> Encode.Value
encode constituency =
    Encode.object
        [ ( "name", Encode.string constituency.name )
        , ( "region_id", Encode.string constituency.regionId )
        , ( "year", Encode.string constituency.year )
        ]


decode : Decode.Decoder Model
decode =
    Decode.map4 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "region_id" Decode.string)
        (Decode.field "year" Decode.string)
