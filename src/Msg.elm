module Msg exposing (Msg(..), decode)

import Json.Decode as Decode
import Model as Model
import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls
import Page.ShowRegions as ShowRegions
import View.GeneralSidebar as GeneralSidebar


type Msg
    = ShowConstituencies ShowConstituencies.Msg
    | ShowCandidates ShowCandidates.Msg
    | ShowParties ShowParties.Msg
    | ShowPolls ShowPolls.Msg
    | ShowRegions ShowRegions.Msg
    | ShowSidebar GeneralSidebar.Msg
    | IncomingMsgError IncomingAppError


type IncomingAppError
    = FailedToLoadConstituencies
    | FailedToLoadCandidates
    | FailedToLoadParties
    | FailedToLoadPolls
    | FailedToLoadRegions
    | NoDecoderMatchFound


decode : Model.Model -> Decode.Value -> Msg
decode model json =
    case Decode.decodeValue (Decode.field "type" Decode.string) json of
        Ok "CandidatesLoaded" ->
            case decodePayload ShowCandidates.decode json of
                Ok candidates ->
                    ShowCandidates (ShowCandidates.CandidatesReceived candidates)

                Err _ ->
                    IncomingMsgError FailedToLoadCandidates

        Ok "ConstituenciesLoaded" ->
            case decodePayload ShowConstituencies.decode json of
                Ok constituencies ->
                    ShowConstituencies (ShowConstituencies.ConstituenciesReceived constituencies)

                Err _ ->
                    IncomingMsgError FailedToLoadConstituencies

        Ok "PollsLoaded" ->
            case decodePayload ShowPolls.decode json of
                Ok polls ->
                    ShowPolls (ShowPolls.PollsReceived polls)

                Err _ ->
                    IncomingMsgError FailedToLoadPolls

        Ok "PartiesLoaded" ->
            case decodePayload ShowParties.decode json of
                Ok parties ->
                    ShowParties (ShowParties.PartiesReceived parties)

                Err _ ->
                    IncomingMsgError FailedToLoadParties

        Ok "RegionsLoaded" ->
            case decodePayload ShowRegions.decode json of
                Ok regions ->
                    ShowRegions (ShowRegions.RegionsReceived regions)

                Err _ ->
                    IncomingMsgError FailedToLoadRegions

        _ ->
            IncomingMsgError NoDecoderMatchFound


decodePayload : Decode.Decoder a -> Decode.Value -> Result Decode.Error a
decodePayload decoder =
    Decode.decodeValue (Decode.field "payload" decoder)
