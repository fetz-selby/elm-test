port module Ports exposing (OutgoingMsg(..), PortData, msgForElm, msgForJs, sendToJs, toPortData)

import Json.Encode as Encode
import View.CandidatesFilter as CandidateFilter
import View.ConstituenciesFilter as ConstituencyFilter
import View.PollsFilter as PollFilter


type OutgoingMsg
    = FetchCandidates CandidateFilter.Model
    | FetchConstituencies ConstituencyFilter.Model
    | FetchPolls PollFilter.Model
    | InitApp
    | InitSidebarApprove
    | InitSidebarRegionalSummary
    | InitSidebarNationalSummary
    | InitSidebarRegion
    | InitSidebarParty
    | InitSidebarPoll
    | InitSidebarCandidate
    | InitSidebarConstituency


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

        InitSidebarRegion ->
            { action = "InitRegions", payload = Encode.null }

        InitSidebarConstituency ->
            { action = "InitConstituencies", payload = Encode.null }

        InitSidebarCandidate ->
            { action = "InitCandidates", payload = Encode.null }

        InitSidebarParty ->
            { action = "InitParties", payload = Encode.null }

        InitSidebarPoll ->
            { action = "InitPolls", payload = Encode.null }

        InitSidebarApprove ->
            { action = "InitApprove", payload = Encode.null }

        InitSidebarRegionalSummary ->
            { action = "InitRegionalSummary", payload = Encode.null }

        InitSidebarNationalSummary ->
            { action = "InitNationalSummary", payload = Encode.null }
