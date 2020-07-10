module Data.Candidate exposing (Model, decode, encode, initCandidate)

import Data.Constituency as Constituency
import Data.Party as Party
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { id : String
    , name : String
    , constituency : Constituency.Model
    , party : Party.Model
    , year : String
    }


initCandidate : Model
initCandidate =
    { id = "", name = "", constituency = Constituency.initConstituency, party = Party.initParty, year = "" }


encode : Model -> Encode.Value
encode candidate =
    Encode.object
        [ ( "name", Encode.string candidate.name )
        , ( "constituency_id", Encode.string candidate.constituency.id )
        , ( "party_id", Encode.string candidate.party.id )
        , ( "year", Encode.string candidate.year )
        ]


decode : Decode.Decoder Model
decode =
    Decode.map5 Model
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "constituency" Constituency.decode)
        (Decode.field "party" Party.decode)
        (Decode.field "year" Decode.string)
