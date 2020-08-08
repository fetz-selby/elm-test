module Data.Candidate exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initCandidate)

import Data.Constituency as Constituency
import Data.Party as Party
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , constituency : Constituency.Model
    , party : Party.Model
    , year : String
    , votes : String
    , candidateType : String
    , avatarPath : String
    , angle : String
    , percentage : String
    , barRatio : String
    }


initCandidate : Model
initCandidate =
    { id = ""
    , name = ""
    , constituency = Constituency.initConstituency
    , party = Party.initParty
    , year = ""
    , votes = "0"
    , candidateType = ""
    , avatarPath = ""
    , angle = "0.0"
    , percentage = "0.0"
    , barRatio = "0.0"
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.votes
        || String.contains search model.constituency.name
        || String.contains search model.party.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , constituency = Constituency.convertModelToLower model.constituency
        , party = Party.convertModelToLower model.party
    }


couldBeNull : Decode.Decoder String
couldBeNull =
    Decode.oneOf
        [ Decode.string, Decode.null "" ]


encode : Model -> Encode.Value
encode candidate =
    Encode.object
        [ ( "id", Encode.string candidate.id )
        , ( "name", Encode.string candidate.name )
        , ( "constituency_id", Encode.string candidate.constituency.id )
        , ( "party_id", Encode.string candidate.party.id )
        , ( "votes", Encode.string candidate.votes )
        , ( "year", Encode.string candidate.year )
        , ( "type", Encode.string candidate.candidateType )
        , ( "avatar_path", Encode.string candidate.avatarPath )
        , ( "angle", Encode.string candidate.angle )
        , ( "percentage", Encode.string candidate.percentage )
        , ( "bar_ratio", Encode.string candidate.barRatio )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "constituency" Constituency.decode
        |> JDP.required "party" Party.decode
        |> JDP.required "year" Decode.string
        |> JDP.required "votes" Decode.string
        |> JDP.required "group_type" Decode.string
        |> JDP.required "avatar_path" couldBeNull
        |> JDP.required "angle" Decode.string
        |> JDP.required "percentage" Decode.string
        |> JDP.required "bar_ratio" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "candidates" (Decode.list decode)
