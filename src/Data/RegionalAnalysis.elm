module Data.RegionalAnalysis exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initRegionalAnalysis
    , isIdExist
    , setAngle
    , setBar
    , setCandidateType
    , setId
    , setParty
    , setPercentage
    , setRegion
    , setStatus
    , setVotes
    )

import Array
import Data.Party as Party
import Data.Region as Region exposing (convertModelToLower, isIdExist)
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , votes : String
    , candidateType : String
    , percentage : String
    , angle : String
    , bar : String
    , party : Party.Model
    , region : Region.Model
    , status : String
    }


initRegionalAnalysis : Model
initRegionalAnalysis =
    { id = ""
    , votes = "0"
    , candidateType = ""
    , percentage = "0.0"
    , angle = "0.0"
    , bar = "0.0"
    , party = Party.initParty
    , region = Region.initRegion
    , status = ""
    }


isIdExist : Model -> List Model -> Bool
isIdExist regionalAnalysis list =
    list |> getOnlyIds |> List.member regionalAnalysis.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


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


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setVotes : String -> Model -> Model
setVotes votes model =
    { model | votes = votes }


setCandidateType : String -> Model -> Model
setCandidateType candidateType model =
    { model | candidateType = candidateType }


setPercentage : String -> Model -> Model
setPercentage percentage model =
    { model | percentage = percentage }


setAngle : String -> Model -> Model
setAngle angle model =
    { model | angle = angle }


setBar : String -> Model -> Model
setBar bar model =
    { model | bar = bar }


setParty : String -> Model -> Model
setParty partyId model =
    { model | party = Party.setId partyId model.party }


setRegion : String -> Model -> Model
setRegion regionId model =
    { model | region = Region.setId regionId model.region }


setStatus : String -> Model -> Model
setStatus status model =
    { model | status = status }


encode : Model -> Encode.Value
encode regional =
    Encode.object
        [ ( "id", Encode.string regional.id )
        , ( "votes", Encode.string regional.votes )
        , ( "type", Encode.string regional.candidateType )
        , ( "region_id", Encode.string regional.region.id )
        , ( "party_id", Encode.string regional.party.id )
        , ( "percentage", Encode.string regional.percentage )
        , ( "angle", Encode.string regional.angle )
        , ( "bar_ratio", Encode.string regional.bar )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "votes" Decode.string
        |> JDP.required "type" Decode.string
        |> JDP.required "percentage" Decode.string
        |> JDP.required "angle" Decode.string
        |> JDP.required "bar" Decode.string
        |> JDP.required "party" Party.decode
        |> JDP.required "region" Region.decode
        |> JDP.required "status" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "regionalAnalysis" (Decode.list decode)
