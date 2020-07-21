module Model exposing (Model, default)

import Page as Page


type alias Model =
    { pages : Page.Page
    , userName : String
    , regionId : String
    }


default : Model
default =
    { pages = Page.default, userName = "", regionId = "" }
