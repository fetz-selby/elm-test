module Msg exposing (IncomingAppError, Msg(..), decode)

import Data.Agent as Agent
import Data.Approve as Approve
import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Data.NationalAnalysis as NationalAnalysis
import Data.ParentConstituency as ParentConstituency
import Data.Party as Party
import Data.Poll as Poll
import Data.Region as Region
import Data.RegionalAnalysis as RegionalAnalysis
import Data.User as User
import Json.Decode as Decode
import Model as Model
import Page.ShowAgents as ShowAgents
import Page.ShowApproves as ShowApproves
import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowNationalAnalysis as ShowNationalAnalysis
import Page.ShowParentConstituencies as ShowParentConstituencies
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls
import Page.ShowRegionalAnalysis as ShowRegionalAnalysis
import Page.ShowRegions as ShowRegions
import Page.ShowUsers as ShowUsers
import View.GeneralSidebar as GeneralSidebar


type Msg
    = ShowConstituencies ShowConstituencies.Msg
    | ShowCandidates ShowCandidates.Msg
    | ShowUsers ShowUsers.Msg
    | ShowAgents ShowAgents.Msg
    | ShowParties ShowParties.Msg
    | ShowPolls ShowPolls.Msg
    | ShowParentConstituencies ShowParentConstituencies.Msg
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
    | FailedToLoadParentConstituencies
    | FailedToLoadRegions
    | FailedToLoadApproves
    | FailedToLoadRegionalAnalysis
    | FailedToLoadNationalAnalysis
    | FailedToLoadAgents
    | FailedToLoadUsers
    | NoDecoderMatchFound


decode : Model.Model -> Decode.Value -> Msg
decode model json =
    case Decode.decodeValue (Decode.field "type" Decode.string) json of
        Ok "CandidatesLoaded" ->
            case decodePayload ShowCandidates.decode json of
                Ok candidateData ->
                    ShowCandidates (ShowCandidates.CandidatesReceived candidateData)

                Err _ ->
                    IncomingMsgError FailedToLoadCandidates

        Ok "UsersLoaded" ->
            case decodePayload ShowUsers.decode json of
                Ok userData ->
                    ShowUsers (ShowUsers.UsersReceived userData)

                Err _ ->
                    IncomingMsgError FailedToLoadCandidates

        Ok "AgentsLoaded" ->
            case decodePayload ShowAgents.decode json of
                Ok agentData ->
                    ShowAgents (ShowAgents.AgentsReceived agentData)

                Err _ ->
                    IncomingMsgError FailedToLoadAgents

        Ok "ConstituenciesLoaded" ->
            case decodePayload ShowConstituencies.decode json of
                Ok constituencyData ->
                    ShowConstituencies (ShowConstituencies.ConstituenciesReceived constituencyData)

                Err _ ->
                    IncomingMsgError FailedToLoadConstituencies

        Ok "PollsLoaded" ->
            case decodePayload ShowPolls.decode json of
                Ok polls ->
                    ShowPolls (ShowPolls.PollsReceived polls)

                Err _ ->
                    IncomingMsgError FailedToLoadPolls

        Ok "ParentConstituenciesLoaded" ->
            case decodePayload ShowParentConstituencies.decode json of
                Ok parentConstituencyData ->
                    ShowParentConstituencies (ShowParentConstituencies.ParentConstituenciesReceived parentConstituencyData)

                Err _ ->
                    IncomingMsgError FailedToLoadParentConstituencies

        Ok "PartiesLoaded" ->
            case decodePayload ShowParties.decode json of
                Ok partyData ->
                    ShowParties (ShowParties.PartiesReceived partyData)

                Err _ ->
                    IncomingMsgError FailedToLoadParties

        Ok "RegionsLoaded" ->
            case decodePayload ShowRegions.decode json of
                Ok regionData ->
                    ShowRegions (ShowRegions.RegionsReceived regionData)

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
                Ok regionalAnalysisData ->
                    ShowRegionalAnalysis (ShowRegionalAnalysis.RegionalAnalysisReceived regionalAnalysisData)

                Err _ ->
                    IncomingMsgError FailedToLoadRegionalAnalysis

        Ok "NationalAnalysisLoaded" ->
            case decodePayload ShowNationalAnalysis.decode json of
                Ok nationalAnalysisData ->
                    ShowNationalAnalysis (ShowNationalAnalysis.NationalAnalysisReceived nationalAnalysisData)

                Err _ ->
                    IncomingMsgError FailedToLoadNationalAnalysis

        -- Add single
        Ok "OneCandidateAdded" ->
            case decodePayload Candidate.decode json of
                Ok candidate ->
                    ShowCandidates (ShowCandidates.AddOne candidate)

                Err _ ->
                    IncomingMsgError FailedToLoadCandidates

        Ok "OneAgentAdded" ->
            case decodePayload Agent.decode json of
                Ok agent ->
                    ShowAgents (ShowAgents.AddOne agent)

                Err err ->
                    let
                        _ =
                            Debug.log "Err[Agent]" err
                    in
                    IncomingMsgError FailedToLoadCandidates

        Ok "OneUserAdded" ->
            case decodePayload User.decode json of
                Ok user ->
                    ShowUsers (ShowUsers.AddOne user)

                Err _ ->
                    IncomingMsgError FailedToLoadUsers

        Ok "OneConstituencyAdd" ->
            case decodePayload Constituency.decode json of
                Ok constituency ->
                    ShowConstituencies (ShowConstituencies.AddOne constituency)

                Err _ ->
                    IncomingMsgError FailedToLoadConstituencies

        Ok "OneParentConstituencyAdd" ->
            case decodePayload ParentConstituency.decode json of
                Ok parentConstituency ->
                    ShowParentConstituencies (ShowParentConstituencies.AddOne parentConstituency)

                Err _ ->
                    IncomingMsgError FailedToLoadParentConstituencies

        Ok "OnePollAdded" ->
            case decodePayload Poll.decode json of
                Ok poll ->
                    ShowPolls (ShowPolls.AddOne poll)

                Err _ ->
                    IncomingMsgError FailedToLoadPolls

        Ok "OnePartyAdded" ->
            case decodePayload Party.decode json of
                Ok party ->
                    ShowParties (ShowParties.AddOne party)

                Err _ ->
                    IncomingMsgError FailedToLoadParties

        Ok "OneRegionAdded" ->
            case decodePayload Region.decode json of
                Ok region ->
                    ShowRegions (ShowRegions.AddOne region)

                Err _ ->
                    IncomingMsgError FailedToLoadRegions

        Ok "OneApproveAdded" ->
            case decodePayload Approve.decode json of
                Ok approve ->
                    ShowApproves (ShowApproves.AddOne approve)

                Err _ ->
                    IncomingMsgError FailedToLoadApproves

        Ok "OneRegionalAnalysisAdded" ->
            case decodePayload RegionalAnalysis.decode json of
                Ok regionalAnalysis ->
                    ShowRegionalAnalysis (ShowRegionalAnalysis.AddOne regionalAnalysis)

                Err _ ->
                    IncomingMsgError FailedToLoadRegionalAnalysis

        Ok "OneNationalAnalysisAdded" ->
            case decodePayload NationalAnalysis.decode json of
                Ok nationalAnalysis ->
                    ShowNationalAnalysis (ShowNationalAnalysis.AddOne nationalAnalysis)

                Err _ ->
                    IncomingMsgError FailedToLoadNationalAnalysis

        _ ->
            IncomingMsgError NoDecoderMatchFound


decodePayload : Decode.Decoder a -> Decode.Value -> Result Decode.Error a
decodePayload decoder =
    Decode.decodeValue (Decode.field "payload" decoder)
