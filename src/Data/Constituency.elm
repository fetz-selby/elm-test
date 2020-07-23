module Data.Constituency exposing (Model, decode, default, encode, initConstituency)

import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , year : String
    , autoCompute : Bool
    , castedVotes : Int
    , isDeclared : Bool
    , parentId : String
    , regVotes : Int
    , rejectVotes : Int
    , seatWonId : String
    , totalVotes : Int
    }


initConstituency : Model
initConstituency =
    { id = ""
    , name = ""
    , year = ""
    , autoCompute = False
    , castedVotes = 0
    , isDeclared = False
    , parentId = ""
    , regVotes = 0
    , rejectVotes = 0
    , seatWonId = ""
    , totalVotes = 0
    }


encode : Model -> Encode.Value
encode constituency =
    Encode.object
        [ ( "name", Encode.string constituency.name )
        , ( "year", Encode.string constituency.year )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "auto_compute" Decode.bool
        |> JDP.required "casted_votes" Decode.int
        |> JDP.required "is_declared" Decode.bool
        |> JDP.required "parent_id" Decode.string
        |> JDP.required "reg_votes" Decode.int
        |> JDP.required "reject_votes" Decode.int
        |> JDP.required "seat_won_id" Decode.string
        |> JDP.required "total_votes" Decode.int


default : Model
default =
    initConstituency
