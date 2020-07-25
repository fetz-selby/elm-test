module Page exposing (Page(..), default)

import Page.ShowApproves as ShowApproves
import Page.ShowCandidates as ShowCandidates
import Page.ShowConstituencies as ShowConstituencies
import Page.ShowNationalAnalysis as ShowNationalAnalysis
import Page.ShowParties as ShowParties
import Page.ShowPolls as ShowPolls
import Page.ShowRegionalAnalysis as ShowRegionalAnalysis
import Page.ShowRegions as ShowRegions


type Page
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates ShowCandidates.Model
    | ShowPolls ShowPolls.Model
    | ShowParties ShowParties.Model
    | ShowRegions ShowRegions.Model
    | ShowApproves ShowApproves.Model
    | ShowRegionalAnalysis ShowRegionalAnalysis.Model
    | ShowNationalAnalysis ShowNationalAnalysis.Model


default : Page
default =
    ShowRegions ShowRegions.default
