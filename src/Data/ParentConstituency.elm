module Data.ParentConstituency exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initParentConstituency
    , setId
    , setName
    , setRegionId
    )

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


encode : Model -> Encode.Value
encode parentConstituency =
    Encode.object
        [ ( "id", Encode.string parentConstituency.id )
        , ( "name", Encode.string parentConstituency.name )
        , ( "region_id", Encode.string parentConstituency.region.id )
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
