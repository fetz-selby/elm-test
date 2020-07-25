export const flatenConstituenciesWithRegionIdIncluded = (
  parentConstituencies,
  constituencies
) =>
  constituencies.reduce((acc, curr) => {
    const foundParentConstituency = parentConstituencies.find(
      (parentConstituency) =>
        parentConstituency.id.toString() === curr.parent_id.toString()
    );

    acc.push({ ...curr, region_id: foundParentConstituency.region_id });
    return acc;
  }, []);

export const normalizePoll = (poll) => ({
  ...poll,
  id: poll && poll.id ? poll.id.toString() : "0",
  name: poll && poll.name ? poll.name : "Unknown",
  year: poll && poll.year ? poll.year.toString() : "",
  total_voters: poll && poll.total_voters ? poll.total_voters.toString() : "0",
  constituency: normalizeConstituency(poll.constituency),
});

export const normalizeRegion = (region) => ({
  ...region,
  id: region && region.id ? region.id.toString() : "0",
  name: region && region.name ? region.name : "Unknown",
  seats: region && region.seats ? parseInt(region.seats) : 0,
});

export const normalizeParty = (party) => ({
  ...party,
  id: party && party.id ? party.id.toString() : "0",
  name: party && party.name ? party.name : "Unknown",
  color: party && party.color ? party.color : "Unknown",
  logo_path: party && party.logo_path ? party.logo_path : "Unknown",
});

export const normalizeConstituency = (constituency) => ({
  ...constituency,
  id: constituency && constituency.id ? constituency.id.toString() : "0",
  name: constituency && constituency.name ? constituency.name : "Unknown",
  year: constituency && constituency.year.toString() ? constituency.year : "",
  casted_votes:
    constituency && constituency.casted_votes
      ? parseInt(constituency.casted_votes)
      : 0,
  parent_id:
    constituency && constituency.parent_id ? constituency.parent_id : "0",
  reg_votes:
    constituency && constituency.reg_votes
      ? parseInt(constituency.reg_votes)
      : 0,
  reject_votes:
    constituency && constituency.reject_votes
      ? parseInt(constituency.reg_votes)
      : 0,
  seat_won_id:
    constituency && constituency.seat_won_id ? constituency.seat_won_id : "",
  total_votes:
    constituency && constituency.total_votes
      ? parseInt(constituency.total_votes)
      : 0,
  is_declared: !!(
    constituency && constituency.is_declared.toLowerCase() === "y"
  ),
  auto_compute: !!(
    constituency && constituency.auto_compute.toLowerCase() === "t"
  ),
});

export const normalizeCandidate = (candidate) => ({
  ...candidate,
  id: candidate && candidate.id ? candidate.id.toString() : "0",
  name: candidate && candidate.name ? candidate.name : "Unknown",
  votes: candidate && candidate.votes ? parseInt(candidate.votes) : 0,
  year: candidate && candidate.year ? candidate.year.toString() : "",
  party: normalizeParty(candidate.party),
  constituency: normalizeConstituency(candidate.constituency),
  group_type: candidate && candidate.group_type ? candidate.group_type : "",
  avatar_path: candidate && candidate.avatar_path ? candidate.avatar_path : "",
  bar_ratio:
    candidate && candidate.bar_ratio ? parseFloat(candidate.bar_ratio) : 0.0,
  percentage:
    candidate && candidate.percentage ? parseFloat(candidate.percentage) : 0.0,
  angle: candidate && candidate.angle ? parseFloat(candidate.angle) : 0.0,
});

export const normalizeAgent = (agent) => ({
  ...agent,
  id: agent && agent.id ? agent.id.toString() : "0",
  name: agent && agent.name ? agent.name : "Unknown",
  msisdn: agent && agent.msisdn ? agent.msisdn : "+000000000",
});

export const normalizeApprove = (approve) => ({
  ...approve,
  id: approve && approve.id ? approve.id.toString() : "",
  message: approve && approve.message ? approve.message : "No Message",
  constituency: normalizeConstituency(approve.constituency),
  region: normalizeRegion(approve.region),
  poll: normalizePoll(approve.poll),
  agent: normalizeAgent(approve.agent),
  year: approve && approve.year ? approve.year.toString() : "",
  type: approve && approve.type ? approve.type : "",
  msisdn: approve && approve.msisdn ? approve.msisdn : "+000000000",
  posted_ts: approve && approve.posted_ts ? approve.posted_ts : "",
  status: approve && approve.status ? approve.status : "D",
});

export const normalizeNationalAnalysis = (nationalAnalysis) => ({
  ...nationalAnalysis,
  id:
    nationalAnalysis && nationalAnalysis.id.toString()
      ? nationalAnalysis.id
      : "",
  party: normalizeParty(nationalAnalysis.party),
  year:
    nationalAnalysis && nationalAnalysis.year
      ? nationalAnalysis.year.toString()
      : "",
  type: nationalAnalysis && nationalAnalysis.type ? nationalAnalysis.type : "",
  percentage:
    nationalAnalysis && nationalAnalysis.percentage
      ? parseFloat(nationalAnalysis.percentage)
      : 0.0,
  angle:
    nationalAnalysis && nationalAnalysis.angle
      ? parseFloat(nationalAnalysis.angle)
      : 0.0,
  bar:
    nationalAnalysis && nationalAnalysis.bar
      ? parseFloat(nationalAnalysis.bar)
      : 0.0,
});

export const normalizeRegionalAnalysis = (regionalAnalysis) => ({
  ...regionalAnalysis,
  id:
    regionalAnalysis && regionalAnalysis.id
      ? regionalAnalysis.id.toString()
      : "0",
  votes:
    regionalAnalysis && regionalAnalysis.votes
      ? parseInt(regionalAnalysis.votes)
      : 0,
  party: normalizeParty(regionalAnalysis.party),
  region: normalizeRegion(regionalAnalysis.region),
  year:
    regionalAnalysis && regionalAnalysis.year
      ? regionalAnalysis.year.toString()
      : "",
  type: regionalAnalysis && regionalAnalysis.type ? regionalAnalysis.type : "",
  percentage:
    regionalAnalysis && regionalAnalysis.percentage
      ? parseFloat(regionalAnalysis.percentage)
      : 0.0,
  angle:
    regionalAnalysis && regionalAnalysis.angle
      ? parseFloat(regionalAnalysis.angle)
      : 0.0,
  bar:
    regionalAnalysis && regionalAnalysis.bar
      ? parseFloat(regionalAnalysis.bar)
      : 0.0,
  status:
    regionalAnalysis && regionalAnalysis.status ? regionalAnalysis.status : "",
});

export const normalizeApproves = (apporoves) =>
  apporoves && apporoves.length
    ? apporoves.map((approve) => normalizeApprove(approve))
    : [];

export const normalizeCandidates = (candidates) =>
  candidates && candidates.length
    ? candidates.map((candidate) => normalizeCandidate(candidate))
    : [];

export const normalizeConstituencies = (constituencies) =>
  constituencies && constituencies.length
    ? constituencies.map((constituency) => normalizeConstituency(constituency))
    : [];

export const normalizeAllNationalAnalysis = (allNationalAnalysis) =>
  allNationalAnalysis && allNationalAnalysis.length
    ? allNationalAnalysis.map((nationalAnalysis) =>
        normalizeNationalAnalysis(nationalAnalysis)
      )
    : [];

export const normalizeAllRegionalAnalysis = (allRegionalAnalysis) =>
  allRegionalAnalysis && allRegionalAnalysis.length
    ? allRegionalAnalysis.map((regionalAnalysis) =>
        normalizeRegionalAnalysis(regionalAnalysis)
      )
    : [];
