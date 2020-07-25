module Page exposing (Page(..), default)

import Page.ShowApproves as ShowApproves
import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls
import Page.ShowRegions as ShowRegions


type Page
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates ShowCandidates.Model
    | ShowPolls ShowPolls.Model
    | ShowParties ShowParties.Model
    | ShowRegions ShowRegions.Model
    | ShowApproves ShowApproves.Model


default : Page
default =
    ShowRegions ShowRegions.default
