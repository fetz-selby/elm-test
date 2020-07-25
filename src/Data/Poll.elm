module Data.Poll exposing (Model, decode, encode, initPoll)

import Data.Constituency as Constituency
import Json.Decode as Decode
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , year : String
    , totalVoters : String
    , constituency : Constituency.Model
    }


initPoll : Model
initPoll =
    { id = "", name = "", year = "", totalVoters = "", constituency = Constituency.initConstituency }


encode : Model -> Encode.Value
encode poll =
    Encode.object
        [ ( "name", Encode.string poll.name )
        , ( "constituency_id", Encode.string poll.constituency.id )
        , ( "year", Encode.string poll.year )
        , ( "total_voters", Encode.string poll.totalVoters )
        ]


decode : Decode.Decoder Model
decode =
    Decode.succeed Model
        |> JDP.required "id" Decode.string
        |> JDP.required "name" Decode.string
        |> JDP.required "year" Decode.string
        |> JDP.required "total_voters" Decode.string
        |> JDP.required "constituency" Constituency.decode
