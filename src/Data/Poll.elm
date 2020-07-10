module Data.Poll exposing (Model, initPoll)

import Data.Constituency as Constituency


type alias Model =
    { id : String
    , name : String
    , constituency : Constituency.Model
    }


initPoll : Model
initPoll =
    { id = "", name = "", constituency = Constituency.initConstituency }
