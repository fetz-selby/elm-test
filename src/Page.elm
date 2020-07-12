module Page exposing (Msg(..), default)

import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls


type Msg
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates ShowCandidates.Model
    | ShowPolls ShowPolls.Model
    | ShowParties ShowParties.Model


default : Msg
default =
    ShowConstituencies ShowConstituencies.default
