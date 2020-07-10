module Page exposing (Msg(..))

import Page.ShowConstituencies as ShowConstituencies
import Page.ShowPolls as ShowPolls


type Msg
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates
    | ShowPolls ShowPolls.Model
    | ShowParties
