module Data.NationalAnalysis exposing (Model, decode, encode, initNationalAnalysis)

import Data.Party as Party
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
    }


initNationalAnalysis : Model
initNationalAnalysis =
    { id = ""
    , votes = 0
    , candidateType = ""
    , percentage = 0.0
    , angle = 0.0
    , bar = 0.0
    , party = Party.initParty
    }


encode : Model -> Encode.Value
encode national =
    Encode.object
        [ ( "name", Encode.string national.candidateType )
        , ( "msisdn", Encode.float national.bar )
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
