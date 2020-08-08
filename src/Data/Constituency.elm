module Data.Constituency exposing (Model, convertModelToLower, decode, decodeList, default, encode, filter, initConstituency)

import Data.Party as Party
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , year : String
    , autoCompute : Bool
    , castedVotes : String
    , isDeclared : Bool
    , parentId : String
    , regVotes : String
    , rejectVotes : String
    , seatWonId : String
    , totalVotes : String
    , party : Party.Model
    }


initConstituency : Model
initConstituency =
    { id = ""
    , name = ""
    , year = ""
    , autoCompute = False
    , castedVotes = "0"
    , isDeclared = False
    , parentId = ""
    , regVotes = "0"
    , rejectVotes = "0"
    , seatWonId = ""
    , totalVotes = "0"
    , party = Party.initParty
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | name = String.toLower model.name }


convertBoolToString : Bool -> String
convertBoolToString state =
    if state then
        "T"

    else
        "F"


encode : Model -> Encode.Value
encode constituency =
    Encode.object
        [ ( "id", Encode.string constituency.id )
        , ( "name", Encode.string constituency.name )
        , ( "year", Encode.string constituency.year )
        , ( "auto_compute", Encode.string (convertBoolToString constituency.autoCompute) )
        , ( "casted_votes", Encode.string constituency.castedVotes )
        , ( "is_declared", Encode.string (convertBoolToString constituency.isDeclared) )
        , ( "parent_id", Encode.string constituency.parentId )
        , ( "reg_votes", Encode.string constituency.regVotes )
        , ( "seat_won_id", Encode.string constituency.seatWonId )
        , ( "total_votes", Encode.string constituency.totalVotes )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "auto_compute" Decode.bool
        |> JDP.required "casted_votes" Decode.string
        |> JDP.required "is_declared" Decode.bool
        |> JDP.required "parent_id" Decode.string
        |> JDP.required "reg_votes" Decode.string
        |> JDP.required "reject_votes" Decode.string
        |> JDP.required "seat_won_id" Decode.string
        |> JDP.required "total_votes" Decode.string
        |> JDP.required "party" Party.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "constituencies" (Decode.list decode)


default : Model
default =
    initConstituency
