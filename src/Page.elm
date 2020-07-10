module Page exposing (Msg(..))

import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowPolls as ShowPolls


type Msg
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates ShowCandidates.Model
    | ShowPolls ShowPolls.Model
