module Page exposing (Page(..), default)

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


type Page
    = ShowConstituencies ShowConstituencies.Model
    | ShowCandidates ShowCandidates.Model
    | ShowAgents ShowAgents.Model
    | ShowPolls ShowPolls.Model
    | ShowParentConstituencies ShowParentConstituencies.Model
    | ShowParties ShowParties.Model
    | ShowRegions ShowRegions.Model
    | ShowApproves ShowApproves.Model
    | ShowRegionalAnalysis ShowRegionalAnalysis.Model
    | ShowNationalAnalysis ShowNationalAnalysis.Model
    | ShowUsers ShowUsers.Model


default : Page
default =
    ShowRegions ShowRegions.default
