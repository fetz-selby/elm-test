module View.Sidebar exposing (Msg(..), view)

import Html exposing (div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type Msg
    = Constituencies
    | Regions
    | Candidates
    | Polls
    | Approve
    | Summary


view : Html.Html Msg
view =
    div
        []
        [ menu "Regions" Regions
        , menu "Constituency" Constituencies
        , menu "Candidates" Candidates
        , menu "Polls" Polls
        , menu "Approve" Approve
        , menu "Summary" Summary
        ]


menu : String -> Msg -> Html.Html Msg
menu label event =
    div
        [ onClick event ]
        [ text label
        ]
