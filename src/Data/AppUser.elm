module Data.AppUser exposing (Model, decode, default, getInitials)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP


type alias Model =
    { id : String
    , name : String
    , email : String
    , msisdn : String
    , region : String
    , level : String
    , isExternal : Bool
    , year : String
    }


getInitials : Model -> String
getInitials model =
    model.name
        |> String.split " "
        |> List.map (\n -> String.left 1 n)
        |> String.concat
        |> String.toUpper


default : Model
default =
    { id = "0"
    , name = "Unknown"
    , email = "apollo@codearbeitet.com"
    , msisdn = "004917635710000"
    , region = "Deutschland"
    , level = "U"
    , isExternal = False
    , year = "0000"
    }


decodeModel : Decode.Decoder Model
decodeModel =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "email" Decode.string
        |> JDP.required "msisdn" Decode.string
        |> JDP.required "region" Decode.string
        |> JDP.required "level" Decode.string
        |> JDP.required "is_external_user" Decode.bool
        |> JDP.required "year" Decode.string


decode : Decode.Decoder Model
decode =
    Decode.field "loginUser" decodeModel
