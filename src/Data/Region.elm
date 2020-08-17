module Data.Region exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , getFirstSelect
    , getId
    , initRegion
    , isIdExist
    , isValid
    , modifyName
    , modifySeat
    , replace
    , setId
    , setName
    , setSeats
    )

import Array
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , seats : String
    }


initRegion : Model
initRegion =
    { id = "", name = "", seats = "0" }


isIdExist : Model -> List Model -> Bool
isIdExist region list =
    list |> getOnlyIds |> List.member region.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name || String.contains search model.seats


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | name = String.toLower model.name }


modifyName : String -> Model -> Model
modifyName name model =
    { model | name = name }


modifySeat : String -> Model -> Model
modifySeat seats model =
    { model | seats = seats }


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setSeats : String -> Model -> Model
setSeats seats model =
    { model | seats = seats }


isValid : Model -> Bool
isValid model =
    hasValidName model.name && hasValidSeats model.seats


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


hasValidSeats : String -> Bool
hasValidSeats seats =
    case String.toInt seats of
        Just _ ->
            True

        Nothing ->
            False


getId : Model -> Int
getId model =
    case String.toInt model.id of
        Just val ->
            val

        Nothing ->
            0


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
    { id = "0", name = "Select Region", seats = "0" }


encode : Model -> Encode.Value
encode region =
    Encode.object
        [ ( "id", Encode.string region.id )
        , ( "name", Encode.string region.name )
        , ( "seats", Encode.string region.seats )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "seats" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "regions" (Decode.list decode)
