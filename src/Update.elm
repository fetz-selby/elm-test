module Update exposing (update)

import Model exposing (Model)
import Msg as Msg
import Page as Page
import Page.ShowAgents as ShowAgentsPage
import Page.ShowApproves as ShowApprovesPage
import Page.ShowCandidates as ShowCandidatesPage
import Page.ShowConstituencies as ShowConstituenciesPage
import Page.ShowNationalAnalysis as ShowNationalAnalysisPage
import Page.ShowParentConstituencies as ShowParentConstituenciesPage
import Page.ShowParties as ShowPartiesPage
import Page.ShowPolls as ShowPollsPage
import Page.ShowRegionalAnalysis as ShowRegionalAnalysisPage
import Page.ShowRegions as ShowRegionsPage
import Page.ShowUsers as ShowUsersPage
import Ports
import Sidebar as Sidebar
import View.GeneralSidebar as GeneralSidebar


update : Msg.Msg -> Model -> ( Model, Cmd Msg.Msg )
update msg model =
    case msg of
        Msg.ShowRegions regMsg ->
            case model.pages of
                Page.ShowRegions submodel ->
                    regMsg
                        |> ShowRegionsPage.update submodel
                        |> Tuple.mapFirst (updateWithRegionsPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowRegions)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowCandidates canMsg ->
            case model.pages of
                Page.ShowCandidates submodel ->
                    canMsg
                        |> ShowCandidatesPage.update submodel
                        |> Tuple.mapFirst (updateWithCandidatesPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowCandidates)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowAgents agentMsg ->
            case model.pages of
                Page.ShowAgents submodel ->
                    agentMsg
                        |> ShowAgentsPage.update submodel
                        |> Tuple.mapFirst (updateWithAgentsPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowAgents)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowUsers userMsg ->
            case model.pages of
                Page.ShowUsers submodel ->
                    userMsg
                        |> ShowUsersPage.update submodel
                        |> Tuple.mapFirst (updateWithUsersPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowUsers)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowConstituencies consMsg ->
            case model.pages of
                Page.ShowConstituencies submodel ->
                    consMsg
                        |> ShowConstituenciesPage.update submodel
                        |> Tuple.mapFirst (updateWithConstituenciesPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowConstituencies)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowParties partyMsg ->
            case model.pages of
                Page.ShowParties submodel ->
                    partyMsg
                        |> ShowPartiesPage.update submodel
                        |> Tuple.mapFirst (updateWithPartiesPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowParties)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowPolls pollMsg ->
            case model.pages of
                Page.ShowPolls submodel ->
                    pollMsg
                        |> ShowPollsPage.update submodel
                        |> Tuple.mapFirst (updateWithPollsPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowPolls)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowParentConstituencies parentConslMsg ->
            case model.pages of
                Page.ShowParentConstituencies submodel ->
                    parentConslMsg
                        |> ShowParentConstituenciesPage.update submodel
                        |> Tuple.mapFirst (updateWithParentConstituenciesPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowParentConstituencies)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowApproves approveMsg ->
            case model.pages of
                Page.ShowApproves submodel ->
                    approveMsg
                        |> ShowApprovesPage.update submodel
                        |> Tuple.mapFirst (updateWithApprovesPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowApproves)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowRegionalAnalysis regionalMsg ->
            case model.pages of
                Page.ShowRegionalAnalysis submodel ->
                    regionalMsg
                        |> ShowRegionalAnalysisPage.update submodel
                        |> Tuple.mapFirst (updateWithRegionalPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowRegionalAnalysis)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowNationalAnalysis nationalMsg ->
            case model.pages of
                Page.ShowNationalAnalysis submodel ->
                    nationalMsg
                        |> ShowNationalAnalysisPage.update submodel
                        |> Tuple.mapFirst (updateWithNationalPage model)
                        |> Tuple.mapSecond (Cmd.map Msg.ShowNationalAnalysis)

                _ ->
                    ( model, Cmd.none )

        Msg.ShowSidebar sidebarMsg ->
            case model.sidebar of
                Sidebar.GeneralSidebar submodel ->
                    sidebarMsg
                        |> GeneralSidebar.update submodel
                        |> Tuple.mapFirst (updateWithSidebarView model)
                        |> Tuple.first

                _ ->
                    ( model, Cmd.none )

        Msg.IncomingMsgError errMsg ->
            ( model, Cmd.none )


updateWithCandidatesPage : Model -> ShowCandidatesPage.Model -> Model
updateWithCandidatesPage model pageModel =
    { model | pages = Page.ShowCandidates pageModel, pageTitle = "Candidates" }


updateWithAgentsPage : Model -> ShowAgentsPage.Model -> Model
updateWithAgentsPage model pageModel =
    { model | pages = Page.ShowAgents pageModel, pageTitle = "Agents" }


updateWithRegionsPage : Model -> ShowRegionsPage.Model -> Model
updateWithRegionsPage model pageModel =
    { model | pages = Page.ShowRegions pageModel, pageTitle = "Regions" }


updateWithConstituenciesPage : Model -> ShowConstituenciesPage.Model -> Model
updateWithConstituenciesPage model pageModel =
    { model | pages = Page.ShowConstituencies pageModel, pageTitle = "Constituencies" }


updateWithPartiesPage : Model -> ShowPartiesPage.Model -> Model
updateWithPartiesPage model pageModel =
    { model | pages = Page.ShowParties pageModel, pageTitle = "Parties" }


updateWithPollsPage : Model -> ShowPollsPage.Model -> Model
updateWithPollsPage model pageModel =
    { model | pages = Page.ShowPolls pageModel, pageTitle = "Polls" }


updateWithParentConstituenciesPage : Model -> ShowParentConstituenciesPage.Model -> Model
updateWithParentConstituenciesPage model pageModel =
    { model | pages = Page.ShowParentConstituencies pageModel, pageTitle = "Parent Constituencies" }


updateWithApprovesPage : Model -> ShowApprovesPage.Model -> Model
updateWithApprovesPage model pageModel =
    { model | pages = Page.ShowApproves pageModel, pageTitle = "Approve" }


updateWithRegionalPage : Model -> ShowRegionalAnalysisPage.Model -> Model
updateWithRegionalPage model pageModel =
    { model | pages = Page.ShowRegionalAnalysis pageModel, pageTitle = "Regional Analysis" }


updateWithNationalPage : Model -> ShowNationalAnalysisPage.Model -> Model
updateWithNationalPage model pageModel =
    { model | pages = Page.ShowNationalAnalysis pageModel, pageTitle = "National Analysis" }


updateWithUsersPage : Model -> ShowUsersPage.Model -> Model
updateWithUsersPage model pageModel =
    { model | pages = Page.ShowUsers pageModel, pageTitle = "Users" }


updateWithSidebarView : Model -> GeneralSidebar.Model -> ( Model, Cmd Msg.Msg )
updateWithSidebarView model viewModel =
    case viewModel.current of
        GeneralSidebar.Constituencies ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowConstituencies ShowConstituenciesPage.default
              }
            , Ports.sendToJs Ports.InitSidebarConstituency
            )

        GeneralSidebar.Regions ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowRegions ShowRegionsPage.default
              }
            , Ports.sendToJs Ports.InitSidebarRegion
            )

        GeneralSidebar.Candidates ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowCandidates ShowCandidatesPage.default
              }
            , Ports.sendToJs Ports.InitSidebarCandidate
            )

        GeneralSidebar.Users ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowUsers ShowUsersPage.default
              }
            , Ports.sendToJs Ports.InitSidebarUser
            )

        GeneralSidebar.Agents ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowAgents ShowAgentsPage.default
              }
            , Ports.sendToJs Ports.InitSidebarAgent
            )

        GeneralSidebar.Parties ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowParties ShowPartiesPage.default
              }
            , Ports.sendToJs Ports.InitSidebarParty
            )

        GeneralSidebar.Polls ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowPolls ShowPollsPage.default
              }
            , Ports.sendToJs Ports.InitSidebarPoll
            )

        GeneralSidebar.ParentConstituencies ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowParentConstituencies ShowParentConstituenciesPage.default
              }
            , Ports.sendToJs Ports.InitSidebarParentConstituency
            )

        GeneralSidebar.Approve ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowApproves ShowApprovesPage.default
              }
            , Ports.sendToJs Ports.InitSidebarApprove
            )

        GeneralSidebar.RegionalSummary ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowRegionalAnalysis ShowRegionalAnalysisPage.default
              }
            , Ports.sendToJs Ports.InitSidebarRegionalSummary
            )

        GeneralSidebar.NationalSummary ->
            ( { model
                | sidebar = Sidebar.GeneralSidebar viewModel
                , pages = Page.ShowNationalAnalysis ShowNationalAnalysisPage.default
              }
            , Ports.sendToJs Ports.InitSidebarNationalSummary
            )
