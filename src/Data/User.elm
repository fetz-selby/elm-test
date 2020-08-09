module Data.User exposing (Model, convertModelToLower, decode, decodeList, encode, filter, initUser)

import Data.Region as Region
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , msisdn : String
    , level : String
    , year : String
    , region : Region.Model
    }


initUser : Model
initUser =
    { id = ""
    , name = ""
    , msisdn = ""
    , level = ""
    , year = ""
    , region = Region.initRegion
    }


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.msisdn
        || String.contains search model.region.name
        || String.contains search model.year
        || String.contains search model.level


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , region = Region.convertModelToLower model.region
    }


encode : Model -> Encode.Value
encode user =
    Encode.object
        [ ( "id", Encode.string user.id )
        , ( "name", Encode.string user.name )
        , ( "msisdn", Encode.string user.msisdn )
        , ( "level", Encode.string user.level )
        , ( "year", Encode.string user.year )
        , ( "region_id", Encode.string user.region.id )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "msisdn" Decode.string
        |> JDP.required "level" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "region" Region.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "users" (Decode.list decode)
