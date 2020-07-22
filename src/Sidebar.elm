module Sidebar exposing (Sidebar(..), default)

import View.GeneralSidebar as GeneralSidebar


type Sidebar
    = GeneralSidebar GeneralSidebar.Model
    | Other


default : Sidebar
default =
    GeneralSidebar GeneralSidebar.default
