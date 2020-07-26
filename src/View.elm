module View exposing (view)

import Html exposing (div)
import Html.Attributes exposing (class)
import Model
import Msg exposing (Msg(..))
import Page exposing (Page(..))
import Page.ShowApproves
import Page.ShowCandidates
import Page.ShowConstituencies
import Page.ShowNationalAnalysis
import Page.ShowParties
import Page.ShowPolls
import Page.ShowRegionalAnalysis
import Page.ShowRegions
import Sidebar exposing (Sidebar(..))
import View.GeneralSidebar


view : Model.Model -> Html.Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col-md-2 col-lg-2" ]
            [ sidebarView model
            ]
        , div [ class "col-md-10 col-lg-10" ]
            [ pageView model
            ]
        ]


sidebarView : Model.Model -> Html.Html Msg
sidebarView { sidebar } =
    case sidebar of
        GeneralSidebar model ->
            model
                |> View.GeneralSidebar.view
                |> Html.map Msg.ShowSidebar

        Other ->
            div [] []


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

        Page.ShowApproves model ->
            model
                |> Page.ShowApproves.view
                |> Html.map Msg.ShowApproves

        Page.ShowRegionalAnalysis model ->
            model
                |> Page.ShowRegionalAnalysis.view
                |> Html.map Msg.ShowRegionalAnalysis

        Page.ShowNationalAnalysis model ->
            model
                |> Page.ShowNationalAnalysis.view
                |> Html.map Msg.ShowNationalAnalysis
