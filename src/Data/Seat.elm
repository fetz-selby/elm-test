module Data.Seat exposing
    ( Model
    , decode
    , decodeList
    , encode
    , filter
    , initSeat
    )

import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Data.Party as Party
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , votes : String
    , percentage : String
    , party : Party.Model
    , candidate : Candidate.Model
    , constituency : Constituency.Model
    }


initSeat : Model
initSeat =
    { id = "0"
    , votes = "0"
    , percentage = "0.0"
    , party = Party.initParty
    , candidate = Candidate.initCandidate
    , constituency = Constituency.initConstituency
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.candidate.name
        || String.contains search model.id
        || String.contains search model.votes
        || String.contains search model.constituency.name
        || String.contains search model.party.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | constituency = Constituency.convertModelToLower model.constituency
        , party = Party.convertModelToLower model.party
        , candidate = Candidate.convertModelToLower model.candidate
    }


encode : Model -> Encode.Value
encode seat =
    Encode.object
        [ ( "id", Encode.string seat.id )
        , ( "votes", Encode.string seat.votes )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "votes" Decode.string
        |> JDP.required "percentage" Decode.string
        |> JDP.required "party" Party.decode
        |> JDP.required "candidate" Candidate.decode
        |> JDP.required "constituency" Constituency.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "seats" (Decode.list decode)
