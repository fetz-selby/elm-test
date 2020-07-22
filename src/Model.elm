module Model exposing (Model, default)

import Page as Page
import Sidebar as Sidebar


type alias Model =
    { pages : Page.Page
    , sidebar : Sidebar.Sidebar
    , userName : String
    , regionId : String
    }


default : Model
default =
    { pages = Page.default, sidebar = Sidebar.default, userName = "", regionId = "" }
