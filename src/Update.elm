module Update exposing (update)

import Model exposing (Model)
import Msg as Msg
import Page as Page
import Page.ShowCandidates as ShowCandidatesPage
import Page.ShowConstituencies as ShowConstituenciesPage
import Page.ShowParties as ShowPartiesPage
import Page.ShowPolls as ShowPollsPage


update : Msg.Msg -> Model -> ( Model, Cmd Msg.Msg )
update msg model =
    case msg of
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

        Msg.IncomingMsgError errMsg ->
            ( model, Cmd.none )


updateWithCandidatesPage : Model -> ShowCandidatesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithCandidatesPage model pageModel =
    ( { model | pages = Page.ShowCandidates pageModel }, Cmd.none )


updateWithConstituenciesPage : Model -> ShowConstituenciesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithConstituenciesPage model pageModel =
    ( { model | pages = Page.ShowConstituencies pageModel }, Cmd.none )


updateWithPartiesPage : Model -> ShowPartiesPage.Model -> ( Model, Cmd Msg.Msg )
updateWithPartiesPage model pageModel =
    ( { model | pages = Page.ShowParties pageModel }, Cmd.none )


updateWithPollsPage : Model -> ShowPollsPage.Model -> ( Model, Cmd Msg.Msg )
updateWithPollsPage model pageModel =
    ( { model | pages = Page.ShowPolls pageModel }, Cmd.none )
