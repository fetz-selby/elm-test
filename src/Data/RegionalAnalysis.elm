module Data.RegionalAnalysis exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initRegionalAnalysis)

import Data.Party as Party
import Data.Region as Region exposing (convertModelToLower)
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , votes : String
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
    , votes = "0"
    , candidateType = ""
    , percentage = 0.0
    , angle = 0.0
    , bar = 0.0
    , party = Party.initParty
    , region = Region.initRegion
    , status = ""
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.party.name
        || String.contains search model.region.name
        || String.contains search model.candidateType
        || String.contains search model.votes


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | party = Party.convertModelToLower model.party
        , candidateType = String.toLower model.candidateType
        , region = Region.convertModelToLower model.region
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
        |> JDP.required "votes" Decode.string
        |> JDP.required "type" Decode.string
        |> JDP.required "percentage" Decode.float
        |> JDP.required "angle" Decode.float
        |> JDP.required "bar" Decode.float
        |> JDP.required "party" Party.decode
        |> JDP.required "region" Region.decode
        |> JDP.required "status" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "regionalAnalysis" (Decode.list decode)
