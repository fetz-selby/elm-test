module Data.Agent exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initAgent)

import Data.Constituency as Constituency
import Data.Poll as Poll
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , msisdn : String
    , pin : String
    , constituency : Constituency.Model
    , poll : Poll.Model
    }


initAgent : Model
initAgent =
    { id = ""
    , name = ""
    , msisdn = ""
    , pin = ""
    , constituency = Constituency.initConstituency
    , poll = Poll.initPoll
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name || String.contains search model.msisdn


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | name = String.toLower model.name }


encode : Model -> Encode.Value
encode agent =
    Encode.object
        [ ( "id", Encode.string agent.id )
        , ( "name", Encode.string agent.name )
        , ( "msisdn", Encode.string agent.msisdn )
        , ( "pin", Encode.string agent.pin )
        , ( "cons_id", Encode.string agent.constituency.id )
        , ( "poll_id", Encode.string agent.poll.id )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "msisdn" Decode.string
        |> JDP.required "pin" Decode.string
        |> JDP.required "constituency" Constituency.decode
        |> JDP.required "poll" Poll.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "agents" (Decode.list decode)
