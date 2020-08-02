module Data.ParentConstituency exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initParentConstituency)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    }


initParentConstituency : Model
initParentConstituency =
    { id = "", name = "" }


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


encode : Model -> Encode.Value
encode agent =
    Encode.object
        [ ( "name", Encode.string agent.name )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "parentConstituencies" (Decode.list decode)
