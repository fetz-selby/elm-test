module View exposing (view)

import Html exposing (div)
import Html.Attributes exposing (class)
import LandingApp exposing (LandingApp(..))
import Model
import Msg exposing (Msg(..))
import Page exposing (Page(..))
import Page.ShowAgents
import Page.ShowApproves
import Page.ShowCandidates
import Page.ShowConstituencies
import Page.ShowNationalAnalysis
import Page.ShowParentConstituencies
import Page.ShowParties
import Page.ShowPolls
import Page.ShowRegionalAnalysis exposing (renderField)
import Page.ShowRegions
import Page.ShowUsers
import Sidebar exposing (Sidebar(..))
import View.GeneralSidebar
import View.LoginView


view : Model.Model -> Html.Html Msg
view model =
    if model.isLogin then
        landingView model

    else
        renderApp model


renderApp : Model.Model -> Html.Html Msg
renderApp model =
    div [ class "row container" ]
        [ div [ class "col-md-2 col-lg-2 sidebar-container" ]
            [ sidebarView model
            ]
        , div [ class "col-md-10 col-lg-10" ]
            [ div [ class "col-md-12 app-title" ]
                [ Html.text model.pageTitle ]
            , pageView model
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


landingView : Model.Model -> Html.Html Msg
landingView { landingApp } =
    case landingApp of
        GeneralLogin model ->
            model
                |> View.LoginView.view
                |> Html.map Msg.ViewLogin

        SpecialPage ->
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

        Page.ShowAgents model ->
            model
                |> Page.ShowAgents.view
                |> Html.map Msg.ShowAgents

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

        Page.ShowParentConstituencies model ->
            model
                |> Page.ShowParentConstituencies.view
                |> Html.map Msg.ShowParentConstituencies

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

        Page.ShowUsers model ->
            model
                |> Page.ShowUsers.view
                |> Html.map Msg.ShowUsers
