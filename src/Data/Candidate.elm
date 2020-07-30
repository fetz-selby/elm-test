module Data.Candidate exposing (Model, decode, decodeList, encode, initCandidate)

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
    , votes : Int
    , candidateType : String
    , avatarPath : String
    , angle : Float
    , percentage : Float
    , barRatio : Float
    }


initCandidate : Model
initCandidate =
    { id = ""
    , name = ""
    , constituency = Constituency.initConstituency
    , party = Party.initParty
    , year = ""
    , votes = 0
    , candidateType = ""
    , avatarPath = ""
    , angle = 0.0
    , percentage = 0.0
    , barRatio = 0.0
    }


encode : Model -> Encode.Value
encode candidate =
    Encode.object
        [ ( "name", Encode.string candidate.name )
        , ( "constituency_id", Encode.string candidate.constituency.id )
        , ( "party_id", Encode.string candidate.party.id )
        , ( "year", Encode.string candidate.year )
        , ( "type", Encode.string candidate.candidateType )
        , ( "votes", Encode.int candidate.votes )
        ]


couldBeNull : Decode.Decoder String
couldBeNull =
    Decode.oneOf
        [ Decode.string, Decode.null "" ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "constituency" Constituency.decode
        |> JDP.required "party" Party.decode
        |> JDP.required "year" Decode.string
        |> JDP.required "votes" Decode.int
        |> JDP.required "group_type" Decode.string
        |> JDP.required "avatar_path" couldBeNull
        |> JDP.required "angle" Decode.float
        |> JDP.required "percentage" Decode.float
        |> JDP.required "bar_ratio" Decode.float


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "candidates" (Decode.list decode)
