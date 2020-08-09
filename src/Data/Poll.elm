module Data.Poll exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initPoll
    , setConstituency
    , setId
    , setName
    , setRejectedVotes
    , setTotalVotes
    , setValidVotes
    )

import Data.Constituency as Constituency
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , year : String
    , rejectedVotes : String
    , validVotes : String
    , totalVoters : String
    , constituency : Constituency.Model
    }


initPoll : Model
initPoll =
    { id = ""
    , name = ""
    , year = ""
    , rejectedVotes = ""
    , validVotes = ""
    , totalVoters = ""
    , constituency = Constituency.initConstituency
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.totalVoters
        || String.contains search model.rejectedVotes
        || String.contains search model.validVotes
        || String.contains search model.constituency.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , constituency = Constituency.convertModelToLower model.constituency
    }


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setRejectedVotes : String -> Model -> Model
setRejectedVotes rejectedVotes model =
    { model | rejectedVotes = rejectedVotes }


setValidVotes : String -> Model -> Model
setValidVotes validVotes model =
    { model | validVotes = validVotes }


setTotalVotes : String -> Model -> Model
setTotalVotes totalVoters model =
    { model | totalVoters = totalVoters }


setConstituency : String -> Model -> Model
setConstituency constituencyId model =
    { model | constituency = Constituency.setId constituencyId model.constituency }


encode : Model -> Encode.Value
encode poll =
    Encode.object
        [ ( "id", Encode.string poll.id )
        , ( "name", Encode.string poll.name )
        , ( "cons_id", Encode.string poll.constituency.id )
        , ( "year", Encode.string poll.year )
        , ( "rejected_votes", Encode.string poll.rejectedVotes )
        , ( "valid_votes", Encode.string poll.validVotes )
        , ( "total_voters", Encode.string poll.totalVoters )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "rejected_votes" Decode.string
        |> JDP.required "valid_votes" Decode.string
        |> JDP.required "total_voters" Decode.string
        |> JDP.required "constituency" Constituency.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "polls" (Decode.list decode)
