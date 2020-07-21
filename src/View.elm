module View exposing (view)

import Html exposing (div)
import Model
import Msg exposing (Msg(..))
import Page exposing (Page(..))
import Page.ShowCandidates
import Page.ShowConstituencies
import Page.ShowParties
import Page.ShowPolls
import Page.ShowRegions


view : Model.Model -> Html.Html Msg
view model =
    div []
        [ pageView model
        ]


pageView : Model.Model -> Html.Html Msg
pageView { pages } =
    case pages of
        Page.ShowRegions model ->
            model
                |> Page.ShowRegions.view
                |> Html.map Msg.ShowRegions

        Page.ShowConstituencies model ->
            model
                |> Page.ShowConstituencies.view
                |> Html.map Msg.ShowConstituencies

        Page.ShowCandidates model ->
            model
                |> Page.ShowCandidates.view
                |> Html.map Msg.ShowCandidates

        Page.ShowParties model ->
            model
                |> Page.ShowParties.view
                |> Html.map Msg.ShowParties

        Page.ShowPolls model ->
            model
                |> Page.ShowPolls.view
                |> Html.map Msg.ShowPolls
