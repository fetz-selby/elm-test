module Model exposing (Model, default)

import LandingApp as LandingApp
import Page as Page
import Sidebar as Sidebar


type alias Model =
    { pages : Page.Page
    , pageTitle : String
    , sidebar : Sidebar.Sidebar
    , landingApp : LandingApp.LandingApp
    , userName : String
    , regionId : String
    , isLogin : Bool
    }


default : Model
default =
    { pages = Page.default
    , pageTitle = ""
    , sidebar = Sidebar.default
    , landingApp = LandingApp.default
    , userName = ""
    , regionId = ""
    , isLogin = True
    }
