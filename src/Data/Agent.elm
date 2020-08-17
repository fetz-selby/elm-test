module Data.Agent exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initAgent
    , isIdExist
    , isValid
    , replace
    , setConstituency
    , setId
    , setMsisdn
    , setName
    , setPin
    , setPoll
    )

import Array
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
    { id = "0"
    , name = ""
    , msisdn = ""
    , pin = ""
    , constituency = Constituency.initConstituency
    , poll = Poll.initPoll
    }


isIdExist : Model -> List Model -> Bool
isIdExist agent list =
    list |> getOnlyIds |> List.member agent.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.msisdn
        || String.contains search model.constituency.name
        || String.contains search model.poll.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , constituency = Constituency.convertModelToLower model.constituency
        , poll = Poll.convertModelToLower model.poll
    }


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setMsisdn : String -> Model -> Model
setMsisdn msisdn model =
    { model | msisdn = msisdn }


setPin : String -> Model -> Model
setPin pin model =
    { model | pin = pin }


setConstituency : String -> Model -> Model
setConstituency constituencyId model =
    { model | constituency = Constituency.setId constituencyId model.constituency }


setPoll : String -> Model -> Model
setPoll pollId model =
    { model | poll = Poll.setId pollId model.poll }


isValid : Model -> Bool
isValid model =
    hasValidName model.name
        && hasValidMsisdn model.msisdn
        && hasValidPIN model.pin
        && hasValidConstituencyId model.constituency
        && hasValidPollId model.poll


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


hasValidMsisdn : String -> Bool
hasValidMsisdn msisdn =
    (msisdn
        |> String.length
        |> (<) 9
    )
        && (msisdn |> String.all Char.isDigit)


hasValidPIN : String -> Bool
hasValidPIN pin =
    (pin
        |> String.length
        |> (==) 4
    )
        && (pin |> String.all Char.isDigit)


hasValidConstituencyId : Constituency.Model -> Bool
hasValidConstituencyId constituency =
    constituency |> Constituency.getId |> (<) 0


hasValidPollId : Poll.Model -> Bool
hasValidPollId poll =
    poll |> Poll.getId |> (<) 0


replace : Model -> List Model -> List Model
replace model list =
    list |> List.map (switch model)


switch : Model -> Model -> Model
switch replacer variable =
    if replacer.id == variable.id then
        replacer

    else
        variable


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
