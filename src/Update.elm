module Update exposing (update)

import Model exposing (Model)
import Msg as Msg
import Page as Page
import Page.ShowCandidates as ShowCandidatesPage
import Page.ShowConstituencies as ShowConstituenciesPage
import Page.ShowParties as ShowPartiesPage
import Page.ShowPolls as ShowPollsPage
import Page.ShowRegions as ShowRegionsPage
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
                        |> Tuple.first

                _ ->
                    ( model, Cmd.none )

        Msg.ShowCandidates canMsg ->
            case model.pages of
                Page.ShowCandidates submodel ->
                    canMsg
                        |> ShowCandidatesPage.update submodel
                        |> Tuple.mapFirst (updateWithCandidatesPage model)
                        |> Tuple.first

                _ ->
                    ( model, Cmd.none )

        Msg.ShowConstituencies consMsg ->
            case model.pages of
                Page.ShowConstituencies submodel ->
                    consMsg
                        |> ShowConstituenciesPage.update submodel
                        |> Tuple.mapFirst (updateWithConstituenciesPage model)
                        |> Tuple.first

                _ ->
                    ( model, Cmd.none )

        Msg.ShowParties partyMsg ->
            case model.pages of
                Page.ShowParties submodel ->
                    partyMsg
                        |> ShowPartiesPage.update submodel
                        |> Tuple.mapFirst (updateWithPartiesPage model)
                        |> Tuple.first

                _ ->
                    ( model, Cmd.none )

        Msg.ShowPolls pollMsg ->
            case model.pages of
                Page.ShowPolls submodel ->
                    pollMsg
                        |> ShowPollsPage.update submodel
                        |> Tuple.mapFirst (updateWithPollsPage model)
                        |> Tuple.first

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


updateWithCandidatesPage : Model -> ShowCandidatesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithCandidatesPage model pageModel =
    ( { model | pages = Page.ShowCandidates pageModel }, Cmd.none )


updateWithRegionsPage : Model -> ShowRegionsPage.Model -> ( Model, Cmd Msg.Msg )
updateWithRegionsPage model pageModel =
    ( { model | pages = Page.ShowRegions pageModel }, Cmd.none )


updateWithConstituenciesPage : Model -> ShowConstituenciesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithConstituenciesPage model pageModel =
    ( { model | pages = Page.ShowConstituencies pageModel }, Cmd.none )


updateWithPartiesPage : Model -> ShowPartiesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithPartiesPage model pageModel =
    ( { model | pages = Page.ShowParties pageModel }, Cmd.none )


updateWithPollsPage : Model -> ShowPollsPage.Model -> ( Model, Cmd Msg.Msg )
updateWithPollsPage model pageModel =
    ( { model | pages = Page.ShowPolls pageModel }, Cmd.none )


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

        GeneralSidebar.Approve ->
            ( model
            , Ports.sendToJs Ports.InitSidebarApprove
            )

        GeneralSidebar.Summary ->
            ( model
            , Ports.sendToJs Ports.InitSidebarSummary
            )
