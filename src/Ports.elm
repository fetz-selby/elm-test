port module Ports exposing (OutgoingMsg(..), PortData, msgForElm, msgForJs, sendToJs, toPortData)

import Data.Agent as Agent
import Data.Approve as Approve
import Data.Candidate as Candidate
import Data.Constituency as Constituency
import Data.Login as Login
import Data.NationalAnalysis as NationalAnalysis
import Data.ParentConstituency as ParentConstituency
import Data.Party as Party
import Data.Poll as Poll
import Data.Region as Region
import Data.RegionalAnalysis as RegionalAnalysis
import Data.User as User
import Json.Encode as Encode
import View.CandidatesFilter as CandidateFilter
import View.ConstituenciesFilter as ConstituencyFilter
import View.PollsFilter as PollFilter


type OutgoingMsg
    = FetchCandidates CandidateFilter.Model
    | FetchConstituencies ConstituencyFilter.Model
    | FetchPolls PollFilter.Model
    | InitApp
    | InitSidebarAgent
    | InitSidebarApprove
    | InitSidebarRegionalSummary
    | InitSidebarNationalSummary
    | InitSidebarRegion
    | InitSidebarParty
    | InitSidebarPoll
    | InitSidebarParentConstituency
    | InitSidebarCandidate
    | InitSidebarConstituency
    | InitSidebarUser
    | InitSidebarSeats
    | DeleteAgent String
    | DeleteRegion String
    | DeleteConstituency String
    | DeleteCandidate String
    | DeleteParty String
    | DeletePoll String
    | DeleteApprove String
    | DeleteRegionSummary String
    | DeleteNationalSummary String
    | SaveAgent Agent.Model
    | SaveUser User.Model
    | SaveRegion Region.Model
    | SaveConstituency Constituency.Model
    | SaveParentConstituency ParentConstituency.Model
    | SaveCandidate Candidate.Model
    | SaveParty Party.Model
    | SavePoll Poll.Model
    | SaveRegionSummary RegionalAnalysis.Model
    | SaveNationalSummary NationalAnalysis.Model
    | UpdateRegion Region.Model
    | UpdateUser User.Model
    | UpdateAgent Agent.Model
    | UpdateConstituency Constituency.Model
    | UpdateCandidate Candidate.Model
    | UpdateParty Party.Model
    | UpdatePoll Poll.Model
    | UpdateParentConstituency ParentConstituency.Model
    | UpdateApprove Approve.Model
    | UpdateRegionalSummary RegionalAnalysis.Model
    | UpdateNationalSummary NationalAnalysis.Model
    | FetchUser Login.Model


port msgForJs : PortData -> Cmd msg


port msgForElm : (Encode.Value -> msg) -> Sub msg


type alias PortData =
    { action : String
    , payload : Encode.Value
    }


sendToJs : OutgoingMsg -> Cmd msg
sendToJs =
    toPortData >> msgForJs


toPortData : OutgoingMsg -> PortData
toPortData msg =
    case msg of
        FetchCandidates model ->
            { action = "FetchCandidates", payload = CandidateFilter.encode model }

        FetchConstituencies model ->
            { action = "FetchConstituencies", payload = ConstituencyFilter.encode model }

        FetchPolls model ->
            { action = "FetchPolls", payload = PollFilter.encode model }

        InitApp ->
            { action = "InitApp", payload = Encode.null }

        InitSidebarAgent ->
            { action = "InitAgents", payload = Encode.null }

        InitSidebarRegion ->
            { action = "InitRegions", payload = Encode.null }

        InitSidebarUser ->
            { action = "InitUsers", payload = Encode.null }

        InitSidebarConstituency ->
            { action = "InitConstituencies", payload = Encode.null }

        InitSidebarCandidate ->
            { action = "InitCandidates", payload = Encode.null }

        InitSidebarParty ->
            { action = "InitParties", payload = Encode.null }

        InitSidebarPoll ->
            { action = "InitPolls", payload = Encode.null }

        InitSidebarParentConstituency ->
            { action = "InitParentConstituencies", payload = Encode.null }

        InitSidebarApprove ->
            { action = "InitApprove", payload = Encode.null }

        InitSidebarSeats ->
            { action = "InitSeats", payload = Encode.null }

        InitSidebarRegionalSummary ->
            { action = "InitRegionalSummary", payload = Encode.null }

        InitSidebarNationalSummary ->
            { action = "InitNationalSummary", payload = Encode.null }

        DeleteAgent id ->
            { action = "DeleteAgent", payload = Encode.string id }

        DeleteRegion id ->
            { action = "DeleteRegion", payload = Encode.string id }

        DeleteConstituency id ->
            { action = "DeleteConstituency", payload = Encode.string id }

        DeleteCandidate id ->
            { action = "DeleteCandidate", payload = Encode.string id }

        DeleteParty id ->
            { action = "DeleteParty", payload = Encode.string id }

        DeletePoll id ->
            { action = "DeletePoll", payload = Encode.string id }

        DeleteApprove id ->
            { action = "DeleteApprove", payload = Encode.string id }

        DeleteRegionSummary id ->
            { action = "DeleteRegionSummary", payload = Encode.string id }

        DeleteNationalSummary id ->
            { action = "DeleteNationalSummary", payload = Encode.string id }

        SaveAgent agent ->
            { action = "SaveAgent", payload = Agent.encode agent }

        SaveUser user ->
            { action = "SaveUser", payload = User.encode user }

        SaveRegion region ->
            { action = "SaveRegion", payload = Region.encode region }

        SaveConstituency constituency ->
            { action = "SaveConstituency", payload = Constituency.encode constituency }

        SaveParentConstituency parentConstituency ->
            { action = "SaveParentConstituency", payload = ParentConstituency.encode parentConstituency }

        SaveCandidate candidate ->
            { action = "SaveCandidate", payload = Candidate.encode candidate }

        SaveParty party ->
            { action = "SaveParty", payload = Party.encode party }

        SavePoll poll ->
            { action = "SavePoll", payload = Poll.encode poll }

        SaveRegionSummary regionalAnalysis ->
            { action = "SaveRegionalSummary", payload = RegionalAnalysis.encode regionalAnalysis }

        SaveNationalSummary nationalAnalysis ->
            { action = "SaveNationalSummary", payload = NationalAnalysis.encode nationalAnalysis }

        UpdateApprove approve ->
            { action = "UpdateApprove", payload = Approve.encode approve }

        UpdateParentConstituency parentConstituency ->
            { action = "UpdateParentConstituency", payload = ParentConstituency.encode parentConstituency }

        UpdateRegion region ->
            { action = "UpdateRegion", payload = Region.encode region }

        UpdateUser user ->
            { action = "UpdateUser", payload = User.encode user }

        UpdateAgent agent ->
            { action = "UpdateAgent", payload = Agent.encode agent }

        UpdateConstituency constituency ->
            { action = "UpdateConstituency", payload = Constituency.encode constituency }

        UpdateCandidate candidate ->
            { action = "UpdateCandidate", payload = Candidate.encode candidate }

        UpdateParty party ->
            { action = "UpdateParty", payload = Party.encode party }

        UpdatePoll poll ->
            { action = "UpdatePoll", payload = Poll.encode poll }

        UpdateRegionalSummary regional ->
            { action = "UpdateRegionalSummary", payload = RegionalAnalysis.encode regional }

        UpdateNationalSummary national ->
            { action = "UpdateNationalSummary", payload = NationalAnalysis.encode national }

        FetchUser cred ->
            { action = "FetchUser", payload = Login.encode cred }
