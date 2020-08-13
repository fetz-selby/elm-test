module Data.Region exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initRegion
    , isIdExist
    , modifyName
    , modifySeat
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


encode : Model -> Encode.Value
encode region =
    Encode.object
        [ ( "id", Encode.string region.id )
        , ( "name", Encode.string region.name )
        , ( "seats", Encode.string region.seats )
        ]


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


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "seats" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "regions" (Decode.list decode)
