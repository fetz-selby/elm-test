module Data.User exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initUser
    , isIdExist
    , setEmail
    , setId
    , setLevel
    , setMsisdn
    , setName
    , setPassword
    , setRegionId
    , setYear
    )

import Array
import Data.Region as Region
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , email : String
    , msisdn : String
    , level : String
    , year : String
    , password : String
    , region : Region.Model
    }


initUser : Model
initUser =
    { id = ""
    , name = ""
    , email = ""
    , msisdn = ""
    , level = ""
    , year = ""
    , password = ""
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


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setEmail : String -> Model -> Model
setEmail email model =
    { model | email = email }


setMsisdn : String -> Model -> Model
setMsisdn msisdn model =
    { model | msisdn = msisdn }


setLevel : String -> Model -> Model
setLevel level model =
    { model | level = level }


setYear : String -> Model -> Model
setYear year model =
    { model | year = year }


setPassword : String -> Model -> Model
setPassword password model =
    { model | password = password }


setRegionId : String -> Model -> Model
setRegionId regionId model =
    { model | region = Region.setId regionId model.region }


isIdExist : Model -> List Model -> Bool
isIdExist user list =
    list |> getOnlyIds |> List.member user.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


encode : Model -> Encode.Value
encode user =
    Encode.object
        [ ( "id", Encode.string user.id )
        , ( "name", Encode.string user.name )
        , ( "email", Encode.string user.email )
        , ( "msisdn", Encode.string user.msisdn )
        , ( "level", Encode.string user.level )
        , ( "year", Encode.string user.year )
        , ( "region_id", Encode.string user.region.id )
        , ( "password", Encode.string user.password )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "email" Decode.string
        |> JDP.required "msisdn" Decode.string
        |> JDP.required "level" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "id" Decode.string
        |> JDP.required "region" Region.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "users" (Decode.list decode)
