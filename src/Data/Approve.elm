module Data.Approve exposing (Model, decode, decodeList, encode, initApprove)

import Data.Agent as Agent
import Data.Constituency as Constituency
import Data.Poll as Poll
import Data.Region as Region
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , message : String
    , constituency : Constituency.Model
    , region : Region.Model
    , poll : Poll.Model
    , agent : Agent.Model
    , year : String
    , candidateType : String
    , msisdn : String
    , postedTs : String
    , status : String
    }


initApprove : Model
initApprove =
    { id = ""
    , message = ""
    , constituency = Constituency.initConstituency
    , region = Region.initRegion
    , poll = Poll.initPoll
    , agent = Agent.initAgent
    , year = ""
    , candidateType = ""
    , msisdn = ""
    , postedTs = ""
    , status = ""
    }


encode : Model -> Encode.Value
encode approve =
    Encode.object
        [ ( "message", Encode.string approve.message )
        , ( "constituency_id", Encode.string approve.constituency.id )
        , ( "year", Encode.string approve.year )
        , ( "type", Encode.string approve.candidateType )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "message" Decode.string
        |> JDP.required "constituency" Constituency.decode
        |> JDP.required "region" Region.decode
        |> JDP.required "poll" Poll.decode
        |> JDP.required "agent" Agent.decode
        |> JDP.required "year" Decode.string
        |> JDP.required "type" Decode.string
        |> JDP.required "msisdn" Decode.string
        |> JDP.required "posted_ts" Decode.string
        |> JDP.required "status" Decode.string


decodeList : Decode.Decoder (List Model)
decodeList =
    Decode.field "approves" (Decode.list decode)
