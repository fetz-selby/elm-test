module Data.Poll exposing (Model, decode, encode, initPoll)

import Data.Constituency as Constituency
import Json.Decode as Decode
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
    Decode.map5 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "year" Decode.string)
        (Decode.field "total_voters" Decode.string)
        (Decode.field "constituency" Constituency.decode)
