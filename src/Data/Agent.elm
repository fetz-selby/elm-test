module Data.Agent exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initAgent)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , msisdn : String
    }


initAgent : Model
initAgent =
    { id = "", name = "", msisdn = "" }


encode : Model -> Encode.Value
encode agent =
    Encode.object
        [ ( "name", Encode.string agent.name )
        , ( "msisdn", Encode.string agent.msisdn )
        ]


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name || String.contains search model.msisdn


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | name = String.toLower model.name }


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "msisdn" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "agents" (Decode.list decode)
