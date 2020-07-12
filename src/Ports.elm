port module Ports exposing (..)

import Json.Encode as Encode
import View.CandidatesFilter as CandidateFilter
import View.ConstituenciesFilter as ConstituencyFilter
import View.PollsFilter as PollFilter


type OutgoingMsg
    = FetchCandidates CandidateFilter.Model
    | FetchConstituencies ConstituencyFilter.Model
    | FetchPolls PollFilter.Model
    | InitApp


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
