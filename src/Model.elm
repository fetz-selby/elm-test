module Model exposing (Model)

import Page as Page


type alias Model =
    { pages : Page.Msg
    , userName : String
    , regionId : String
    }
