module Data.Poll exposing
    ( Model
    , addIfNotExist
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , getFirstSelect
    , getId
    , initPoll
    , isIdExist
    , isValid
    , replace
    , setConstituency
    , setId
    , setName
    , setRejectedVotes
    , setTotalVotes
    , setValidVotes
    )

import Array
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
    { id = "0"
    , name = ""
    , year = ""
    , rejectedVotes = ""
    , validVotes = ""
    , totalVoters = ""
    , constituency = Constituency.initConstituency
    }


isIdExist : Model -> List Model -> Bool
isIdExist poll list =
    list |> getOnlyIds |> List.member poll.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


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


getId : Model -> Int
getId model =
    case String.toInt model.id of
        Just val ->
            val

        Nothing ->
            0


isValid : Model -> Bool
isValid model =
    hasValidName model.name
        && hasValidVotes model.rejectedVotes
        && hasValidVotes model.validVotes
        && hasValidVotes model.totalVoters
        && hasValidConstituencyId model.constituency


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


hasValidVotes : String -> Bool
hasValidVotes votes =
    (votes
        |> String.length
        |> (<) 0
    )
        && (votes |> String.all Char.isDigit)


hasValidConstituencyId : Constituency.Model -> Bool
hasValidConstituencyId constituency =
    constituency |> Constituency.getId |> (<) 0


replace : Model -> List Model -> List Model
replace model list =
    list |> List.map (switch model)


switch : Model -> Model -> Model
switch replacer variable =
    if replacer.id == variable.id then
        replacer

    else
        variable


getFirstSelect : Model
getFirstSelect =
    { id = "0"
    , name = "Select Poll"
    , year = ""
    , rejectedVotes = ""
    , validVotes = ""
    , totalVoters = ""
    , constituency = Constituency.initConstituency
    }


addIfNotExist : Model -> List Model -> List Model
addIfNotExist model list =
    if list |> List.any (\n -> n.id == model.id) then
        list

    else
        model :: list


encode : Model -> Encode.Value
encode poll =
    Encode.object
        [ ( "id", Encode.string poll.id )
        , ( "name", Encode.string poll.name )
        , ( "cons_id", Encode.string poll.constituency.id )
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
