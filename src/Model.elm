module Model exposing (Model, default)

import Data.AppUser as AppUser
import LandingApp as LandingApp
import Page as Page
import Sidebar as Sidebar


type alias Model =
    { pages : Page.Page
    , pageTitle : String
    , sidebar : Sidebar.Sidebar
    , landingApp : LandingApp.LandingApp
    , user : AppUser.Model
    , isLogin : Bool
    }


default : Model
default =
    { pages = Page.default
    , pageTitle = ""
    , sidebar = Sidebar.default
    , landingApp = LandingApp.default
    , user = AppUser.default
    , isLogin = True
    }
