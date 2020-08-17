module Data.Constituency exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , default
    , encode
    , filter
    , getFirstSelect
    , getId
    , initConstituency
    , isIdExist
    , isValid
    , replace
    , setAutoCompute
    , setCastedVotes
    , setId
    , setIsDeclared
    , setName
    , setParentId
    , setRegVotes
    , setRejectVotes
    , setSeatWonId
    , setTotalVotes
    )

import Array
import Data.ParentConstituency as ParentConstituency
import Data.Party as Party
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , autoCompute : Bool
    , castedVotes : String
    , isDeclared : Bool
    , parent : ParentConstituency.Model
    , regVotes : String
    , rejectVotes : String
    , seatWonId : Party.Model
    , totalVotes : String
    }


initConstituency : Model
initConstituency =
    { id = ""
    , name = ""
    , autoCompute = False
    , castedVotes = "0"
    , isDeclared = False
    , parent = ParentConstituency.initParentConstituency
    , regVotes = "0"
    , rejectVotes = "0"
    , seatWonId = Party.initParty
    , totalVotes = "0"
    }


isIdExist : Model -> List Model -> Bool
isIdExist constituency list =
    list |> getOnlyIds |> List.member constituency.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | name = String.toLower model.name }


convertBoolToTFString : Bool -> String
convertBoolToTFString state =
    if state then
        "T"

    else
        "F"


convertBoolToYNString : Bool -> String
convertBoolToYNString state =
    if state then
        "Y"

    else
        "N"


convertStringToBool : String -> Bool
convertStringToBool state =
    state |> String.toUpper |> (==) "Y"


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setAutoCompute : String -> Model -> Model
setAutoCompute autoCompute model =
    { model | autoCompute = convertStringToBool autoCompute }


setCastedVotes : String -> Model -> Model
setCastedVotes castedVotes model =
    { model | castedVotes = castedVotes }


setIsDeclared : String -> Model -> Model
setIsDeclared isDeclared model =
    { model | isDeclared = convertStringToBool isDeclared }


setParentId : String -> Model -> Model
setParentId parentId model =
    { model | parent = ParentConstituency.setId parentId model.parent }


setRegVotes : String -> Model -> Model
setRegVotes regVotes model =
    { model | regVotes = regVotes }


setRejectVotes : String -> Model -> Model
setRejectVotes rejectVotes model =
    { model | rejectVotes = rejectVotes }


setSeatWonId : String -> Model -> Model
setSeatWonId seatWonId model =
    { model | seatWonId = Party.setId seatWonId model.seatWonId }


setTotalVotes : String -> Model -> Model
setTotalVotes totalVotes model =
    { model | totalVotes = totalVotes }


isValid : Model -> Bool
isValid model =
    hasValidName model.name
        && hasValidVotes model.castedVotes
        && hasValidVotes model.regVotes
        && hasValidVotes model.rejectVotes
        && hasValidVotes model.totalVotes
        && hasValidParentConstituency model.parent
        && hasValidSeatWonId model.seatWonId


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


hasValidParentConstituency : ParentConstituency.Model -> Bool
hasValidParentConstituency model =
    model |> ParentConstituency.getId |> (<) 0


hasValidSeatWonId : Party.Model -> Bool
hasValidSeatWonId party =
    party |> Party.getId |> (<) 0


getId : Model -> Int
getId model =
    case String.toInt model.id of
        Just val ->
            val

        Nothing ->
            0


getFirstSelect : Model
getFirstSelect =
    { id = "0"
    , name = "Select Constituency"
    , autoCompute = False
    , castedVotes = "0"
    , isDeclared = False
    , parent = ParentConstituency.initParentConstituency
    , regVotes = "0"
    , rejectVotes = "0"
    , seatWonId = Party.initParty
    , totalVotes = "0"
    }


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
encode constituency =
    Encode.object
        [ ( "id", Encode.string constituency.id )
        , ( "name", Encode.string constituency.name )
        , ( "auto_compute", Encode.string (convertBoolToTFString constituency.autoCompute) )
        , ( "casted_votes", Encode.string constituency.castedVotes )
        , ( "is_declared", Encode.string (convertBoolToYNString constituency.isDeclared) )
        , ( "parent_id", Encode.string constituency.parent.id )
        , ( "reg_votes", Encode.string constituency.regVotes )
        , ( "seat_won_id", Encode.string constituency.seatWonId.id )
        , ( "total_votes", Encode.string constituency.totalVotes )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "auto_compute" Decode.bool
        |> JDP.required "casted_votes" Decode.string
        |> JDP.required "is_declared" Decode.bool
        |> JDP.required "parent" ParentConstituency.decode
        |> JDP.required "reg_votes" Decode.string
        |> JDP.required "reject_votes" Decode.string
        |> JDP.required "seat_won_id" Party.decode
        |> JDP.required "total_votes" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "constituencies" (Decode.list decode)


default : Model
default =
    initConstituency
