module Model exposing (Model, default)

import Page as Page
import Sidebar as Sidebar


type alias Model =
    { pages : Page.Page
    , pageTitle : String
    , sidebar : Sidebar.Sidebar
    , userName : String
    , regionId : String
    }


default : Model
default =
    { pages = Page.default, pageTitle = "", sidebar = Sidebar.default, userName = "", regionId = "" }
