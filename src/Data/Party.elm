module Data.Party exposing
    ( Model
    , addIfNotExist
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , getFirstSelect
    , getId
    , initParty
    , isIdExist
    , isValid
    , replace
    , setColor
    , setId
    , setLogoPath
    , setName
    , setOrderQueue
    )

import Array
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
    { id = "23", name = "", color = "", logoPath = "", orderQueue = "0" }


isIdExist : Model -> List Model -> Bool
isIdExist party list =
    list |> getOnlyIds |> List.member party.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.id
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


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setLogoPath : String -> Model -> Model
setLogoPath logoPath model =
    { model | logoPath = logoPath }


setColor : String -> Model -> Model
setColor color model =
    { model | color = color }


setOrderQueue : String -> Model -> Model
setOrderQueue orderQueue model =
    { model | orderQueue = orderQueue }


getId : Model -> Int
getId model =
    case String.toInt model.id of
        Just val ->
            val

        Nothing ->
            0


isValid : Model -> Bool
isValid model =
    hasValidName model.name && hasValidOrderQueue model.orderQueue


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


hasValidOrderQueue : String -> Bool
hasValidOrderQueue orderQueue =
    case String.toInt orderQueue of
        Just _ ->
            True

        Nothing ->
            False


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
    { id = "0", name = "Select Party", color = "", logoPath = "", orderQueue = "0" }


addIfNotExist : Model -> List Model -> List Model
addIfNotExist model list =
    if list |> List.any (\n -> n.id == model.id) then
        list

    else
        model :: list


encode : Model -> Encode.Value
encode party =
    Encode.object
        [ ( "id", Encode.string party.id )
        , ( "name", Encode.string party.name )
        , ( "color", Encode.string party.color )
        , ( "logo_path", Encode.string party.logoPath )
        , ( "order_queue", Encode.string party.orderQueue )
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
