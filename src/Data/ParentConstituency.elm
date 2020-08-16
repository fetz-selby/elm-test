module Data.ParentConstituency exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , getId
    , initParentConstituency
    , isIdExist
    , isValid
    , replace
    , setId
    , setName
    , setRegionId
    )

import Array
import Data.Region as Region
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , region : Region.Model
    }


initParentConstituency : Model
initParentConstituency =
    { id = "", name = "", region = Region.initRegion }


isIdExist : Model -> List Model -> Bool
isIdExist parentConstituency list =
    list |> getOnlyIds |> List.member parentConstituency.id


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
    { model
        | name = String.toLower model.name
    }


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setRegionId : String -> Model -> Model
setRegionId regionId model =
    { model | region = Region.setId regionId model.region }


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


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


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
encode parentConstituency =
    Encode.object
        [ ( "id", Encode.string parentConstituency.id )
        , ( "name", Encode.string parentConstituency.name )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "region" Region.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "parentConstituencies" (Decode.list decode)
