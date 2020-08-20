module LandingApp exposing (LandingApp(..), default)

import View.LoginView as LoginView


type LandingApp
    = GeneralLogin LoginView.Model
    | SpecialPage


default : LandingApp
default =
    GeneralLogin LoginView.default
