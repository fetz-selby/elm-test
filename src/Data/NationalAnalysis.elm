module Data.NationalAnalysis exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , initNationalAnalysis
    , isIdExist
    , isValid
    , replace
    , setAngle
    , setBar
    , setCandidateType
    , setId
    , setPartyId
    , setPercentage
    , setVotes
    )

import Array
import Data.Party as Party exposing (convertModelToLower)
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , votes : String
    , candidateType : String
    , percentage : String
    , angle : String
    , bar : String
    , party : Party.Model
    }


initNationalAnalysis : Model
initNationalAnalysis =
    { id = "0"
    , votes = "0"
    , candidateType = ""
    , percentage = "0.0"
    , angle = "0.0"
    , bar = "0.0"
    , party = Party.initParty
    }


isIdExist : Model -> List Model -> Bool
isIdExist nationalAnalysis list =
    list |> getOnlyIds |> List.member nationalAnalysis.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.party.name
        || String.contains search model.id
        || String.contains search model.candidateType
        || String.contains search model.votes


convertModelToLower : Model -> Model
convertModelToLower model =
    { model | party = Party.convertModelToLower model.party, candidateType = String.toLower model.candidateType }


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setVotes : String -> Model -> Model
setVotes votes model =
    { model | votes = votes }


setCandidateType : String -> Model -> Model
setCandidateType candidateType model =
    { model | candidateType = candidateType }


setPercentage : String -> Model -> Model
setPercentage percentage model =
    { model | percentage = percentage }


setAngle : String -> Model -> Model
setAngle angle model =
    { model | angle = angle }


setBar : String -> Model -> Model
setBar bar model =
    { model | bar = bar }


setPartyId : String -> Model -> Model
setPartyId partyId model =
    { model | party = Party.setId partyId model.party }


isValid : Model -> Bool
isValid model =
    hasValidFigures model.votes
        && hasValidFigures model.percentage
        && hasValidFigures model.angle
        && hasValidFigures model.bar
        && hasValidCandidateType model.candidateType
        && hasValidParty model.party


hasValidFigures : String -> Bool
hasValidFigures figure =
    let
        a =
            case String.toFloat figure of
                Just v ->
                    v

                Nothing ->
                    -1
    in
    (figure
        |> String.length
        |> (<) 0
    )
        && (a |> (<=) 0)


hasValidCandidateType : String -> Bool
hasValidCandidateType candidateType =
    (candidateType |> String.toUpper |> (==) "M")
        || (candidateType
                |> String.toUpper
                |> (==) "P"
           )


hasValidParty : Party.Model -> Bool
hasValidParty party =
    party |> Party.getId |> (<) 0


replace : Model -> List Model -> List Model
replace model list =
    list |> List.map (switch model)


switch : Model -> Model -> Model
switch replacer variable =
    if replacer.id == variable.id then
        replacer

    else
        variable


encode : Model -> Encode.Value
encode national =
    Encode.object
        [ ( "id", Encode.string national.id )
        , ( "votes", Encode.string national.votes )
        , ( "type", Encode.string national.candidateType )
        , ( "percentage", Encode.string national.percentage )
        , ( "angle", Encode.string national.angle )
        , ( "bar", Encode.string national.bar )
        , ( "party_id", Encode.string national.party.id )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "votes" Decode.string
        |> JDP.required "type" Decode.string
        |> JDP.required "percentage" Decode.string
        |> JDP.required "angle" Decode.string
        |> JDP.required "bar" Decode.string
        |> JDP.required "party" Party.decode


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "nationalAnalysis" (Decode.list decode)
