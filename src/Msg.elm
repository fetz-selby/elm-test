module Msg exposing (Msg(..), decode)

import Json.Decode as Decode
import Model as Model
import Page.ShowApproves as ShowApproves
import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowNationalAnalysis as ShowNationalAnalysis
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls
import Page.ShowRegionalAnalysis as ShowRegionalAnalysis
import Page.ShowRegions as ShowRegions
import View.GeneralSidebar as GeneralSidebar


type Msg
    = ShowConstituencies ShowConstituencies.Msg
    | ShowCandidates ShowCandidates.Msg
    | ShowParties ShowParties.Msg
    | ShowPolls ShowPolls.Msg
    | ShowRegions ShowRegions.Msg
    | ShowApproves ShowApproves.Msg
    | ShowRegionalAnalysis ShowRegionalAnalysis.Msg
    | ShowNationalAnalysis ShowNationalAnalysis.Msg
    | ShowSidebar GeneralSidebar.Msg
    | IncomingMsgError IncomingAppError


type IncomingAppError
    = FailedToLoadConstituencies
    | FailedToLoadCandidates
    | FailedToLoadParties
    | FailedToLoadPolls
    | FailedToLoadRegions
    | FailedToLoadApproves
    | FailedToLoadRegionalAnalysis
    | FailedToLoadNationalAnalysis
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

        Ok "ApprovesLoaded" ->
            case decodePayload ShowApproves.decode json of
                Ok approves ->
                    ShowApproves (ShowApproves.ApprovesReceived approves)

                Err _ ->
                    IncomingMsgError FailedToLoadApproves

        Ok "RegionalAnalysisLoaded" ->
            case decodePayload ShowRegionalAnalysis.decode json of
                Ok regionalAnalysis ->
                    ShowRegionalAnalysis (ShowRegionalAnalysis.RegionalAnalysisReceived regionalAnalysis)

                Err err ->
                    let
                        _ =
                            Debug.log "[RegionalAnalysisLoaded] " err
                    in
                    IncomingMsgError FailedToLoadRegionalAnalysis

        Ok "NationalAnalysisLoaded" ->
            case decodePayload ShowNationalAnalysis.decode json of
                Ok nationalAnalysis ->
                    ShowNationalAnalysis (ShowNationalAnalysis.NationalAnalysisReceived nationalAnalysis)

                Err _ ->
                    IncomingMsgError FailedToLoadNationalAnalysis

        _ ->
            IncomingMsgError NoDecoderMatchFound


decodePayload : Decode.Decoder a -> Decode.Value -> Result Decode.Error a
decodePayload decoder =
    Decode.decodeValue (Decode.field "payload" decoder)
