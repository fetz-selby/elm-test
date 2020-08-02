module Data.Party exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initParty)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , color : String
    , logoPath : String
    , orderQueue : String
    }


initParty : Model
initParty =
    { id = "", name = "", color = "", logoPath = "", orderQueue = "0" }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.color
        || String.contains search model.logoPath
        || String.contains search model.orderQueue


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , color = String.toLower model.color
        , logoPath = String.toLower model.logoPath
    }


encode : Model -> Encode.Value
encode party =
    Encode.object
        [ ( "name", Encode.string party.name )
        , ( "color", Encode.string party.color )
        , ( "logo_path", Encode.string party.logoPath )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "color" Decode.string
        |> JDP.required "logo_path" Decode.string
        |> JDP.required "order_queue" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "parties" (Decode.list decode)
