module Data.Candidate exposing
    ( Model
    , convertModelToLower
    , decode
    , decodeList
    , encode
    , filter
    , getId
    , initCandidate
    , isIdExist
    , isValid
    , setAngle
    , setAvatarPath
    , setBarRatio
    , setCandidateType
    , setConstituency
    , setId
    , setName
    , setParty
    , setPercentage
    , setVotes
    )

import Array
import Data.Constituency as Constituency
import Data.Party as Party
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , constituency : Constituency.Model
    , party : Party.Model
    , votes : String
    , candidateType : String
    , avatarPath : String
    , angle : String
    , percentage : String
    , barRatio : String
    }


initCandidate : Model
initCandidate =
    { id = ""
    , name = ""
    , constituency = Constituency.initConstituency
    , party = Party.initParty
    , votes = "0"
    , candidateType = ""
    , avatarPath = ""
    , angle = "0.0"
    , percentage = "0.0"
    , barRatio = "0.0"
    }


isIdExist : Model -> List Model -> Bool
isIdExist candidate list =
    list |> getOnlyIds |> List.member candidate.id


getOnlyIds : List Model -> List String
getOnlyIds list =
    list |> Array.fromList |> Array.map (\n -> n.id) |> Array.toList


filter : String -> List Model -> List Model
filter search list =
    List.filter (\model -> model |> convertModelToLower |> isFound (String.toLower search)) list


isFound : String -> Model -> Bool
isFound search model =
    String.contains search model.name
        || String.contains search model.votes
        || String.contains search model.constituency.name
        || String.contains search model.party.name


convertModelToLower : Model -> Model
convertModelToLower model =
    { model
        | name = String.toLower model.name
        , constituency = Constituency.convertModelToLower model.constituency
        , party = Party.convertModelToLower model.party
    }


couldBeNull : Decode.Decoder String
couldBeNull =
    Decode.oneOf
        [ Decode.string, Decode.null "" ]


setId : String -> Model -> Model
setId id model =
    { model | id = id }


setName : String -> Model -> Model
setName name model =
    { model | name = name }


setConstituency : String -> Model -> Model
setConstituency constituencyId model =
    { model | constituency = Constituency.setId constituencyId model.constituency }


setParty : String -> Model -> Model
setParty partyId model =
    { model | party = Party.setId partyId model.party }


setVotes : String -> Model -> Model
setVotes votes model =
    { model | votes = votes }


setCandidateType : String -> Model -> Model
setCandidateType candidateType model =
    { model | candidateType = candidateType }


setAvatarPath : String -> Model -> Model
setAvatarPath avatarPath model =
    { model | avatarPath = avatarPath }


setAngle : String -> Model -> Model
setAngle angle model =
    { model | angle = angle }


setPercentage : String -> Model -> Model
setPercentage percentage model =
    { model | percentage = percentage }


setBarRatio : String -> Model -> Model
setBarRatio barRatio model =
    { model | barRatio = barRatio }


getId : Model -> Int
getId model =
    case String.toInt model.id of
        Just val ->
            val

        Nothing ->
            0


isValid : Model -> Bool
isValid model =
    hasValidName model.name
        && hasValidFigures model.percentage
        && hasValidFigures model.angle
        && hasValidFigures model.barRatio
        && hasValidFigures model.votes
        && hasValidCandidateType model.candidateType
        && hasValidParty model.party
        && hasValidConstituency model.constituency


hasValidName : String -> Bool
hasValidName name =
    name |> String.length |> (<) 2


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


hasValidConstituency : Constituency.Model -> Bool
hasValidConstituency constituency =
    constituency |> Constituency.getId |> (<) 0


encode : Model -> Encode.Value
encode candidate =
    Encode.object
        [ ( "id", Encode.string candidate.id )
        , ( "name", Encode.string candidate.name )
        , ( "constituency_id", Encode.string candidate.constituency.id )
        , ( "party_id", Encode.string candidate.party.id )
        , ( "votes", Encode.string candidate.votes )
        , ( "type", Encode.string candidate.candidateType )
        , ( "avatar_path", Encode.string candidate.avatarPath )
        , ( "angle", Encode.string candidate.angle )
        , ( "percentage", Encode.string candidate.percentage )
        , ( "bar_ratio", Encode.string candidate.barRatio )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "constituency" Constituency.decode
        |> JDP.required "party" Party.decode
        |> JDP.required "votes" Decode.string
        |> JDP.required "group_type" Decode.string
        |> JDP.required "avatar_path" couldBeNull
        |> JDP.required "angle" Decode.string
        |> JDP.required "percentage" Decode.string
        |> JDP.required "bar_ratio" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "candidates" (Decode.list decode)
