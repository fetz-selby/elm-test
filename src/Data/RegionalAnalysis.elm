module Data.RegionalAnalysis exposing (Model, decode, encode, initRegionalAnalysis)

import Data.Party as Party
import Data.Region as Region
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , votes : Int
    , candidateType : String
    , percentage : Float
    , angle : Float
    , bar : Float
    , party : Party.Model
    , region : Region.Model
    , status : String
    }


initRegionalAnalysis : Model
initRegionalAnalysis =
    { id = ""
    , votes = 0
    , candidateType = ""
    , percentage = 0.0
    , angle = 0.0
    , bar = 0.0
    , party = Party.initParty
    , region = Region.initRegion
    , status = ""
    }


encode : Model -> Encode.Value
encode regional =
    Encode.object
        [ ( "name", Encode.string regional.candidateType )
        , ( "msisdn", Encode.float regional.bar )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "votes" Decode.int
        |> JDP.required "type" Decode.string
        |> JDP.required "percentage" Decode.float
        |> JDP.required "angle" Decode.float
        |> JDP.required "bar" Decode.float
        |> JDP.required "party" Party.decode
        |> JDP.required "region" Region.decode
        |> JDP.required "status" Decode.string
