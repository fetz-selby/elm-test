const sort = (a, b) =>
  a.name.toLowerCase() === b.name.toLowerCase()
    ? 0
    : a.name.toLowerCase() < b.name.toLowerCase()
    ? -1
    : 1;

export const PASS = "thequickfoxjumpedoverthelazydog";

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
  rejected_votes:
    poll && poll.rejected_votes ? poll.rejected_votes.toString() : "0",
  valid_votes: poll && poll.valid_votes ? poll.valid_votes.toString() : "0",
  total_voters: poll && poll.total_voters ? poll.total_voters.toString() : "0",
  constituency:
    poll && poll.constituency
      ? normalizeConstituency(poll.constituency)
      : normalizeConstituency({}),
});

export const normalizeRegion = (region) => ({
  ...region,
  id: region && region.id ? region.id.toString() : "0",
  name: region && region.name ? region.name : "Unknown",
  seats: region && region.seats ? region.seats.toString() : "0",
});

export const normalizeParty = (party) => ({
  ...party,
  id: party && party.id ? party.id.toString() : "0",
  name: party && party.name ? party.name : "Unknown",
  color: party && party.color ? party.color : "Unknown",
  logo_path: party && party.logo_path ? party.logo_path : "Unknown",
  order_queue: party && party.order_queue ? party.order_queue.toString() : "0",
});

export const normalizeConstituency = (constituency) => {
  return {
    ...constituency,
    id: constituency && constituency.id ? constituency.id.toString() : "0",
    name: constituency && constituency.name ? constituency.name : "Unknown",
    year: constituency && constituency.year ? constituency.year.toString() : "",
    casted_votes:
      constituency && constituency.casted_votes
        ? constituency.casted_votes.toString()
        : "0",
    parent:
      constituency && constituency.parent_constituency
        ? normalizeParentConstituency(constituency.parent_constituency)
        : normalizeParentConstituency({}),
    reg_votes:
      constituency && constituency.reg_votes
        ? constituency.reg_votes.toString()
        : "0",
    reject_votes:
      constituency && constituency.reject_votes
        ? constituency.reg_votes.toString()
        : "0",
    seat_won_id:
      constituency && constituency.party
        ? normalizeParty(constituency.party)
        : normalizeParty({}),
    total_votes:
      constituency && constituency.total_votes
        ? constituency.total_votes.toString()
        : "0",
    is_declared: !!(
      constituency &&
      constituency.is_declared &&
      constituency.is_declared.toLowerCase() === "y"
    ),
    auto_compute: !!(
      constituency &&
      constituency.auto_compute &&
      constituency.auto_compute.toLowerCase() === "t"
    ),
  };
};

export const normalizeCandidate = (candidate) => ({
  ...candidate,
  id: candidate && candidate.id ? candidate.id.toString() : "0",
  name: candidate && candidate.name ? candidate.name : "Unknown",
  votes: candidate && candidate.votes ? candidate.votes.toString() : "0",
  year: candidate && candidate.year ? candidate.year.toString() : "",
  party:
    candidate && candidate.party
      ? normalizeParty(candidate.party)
      : normalizeParty({}),
  constituency:
    candidate && candidate.constituency
      ? normalizeConstituency(candidate.constituency)
      : normalizeConstituency({}),
  group_type: candidate && candidate.group_type ? candidate.group_type : "",
  avatar_path: candidate && candidate.avatar_path ? candidate.avatar_path : "",
  bar_ratio:
    candidate && candidate.bar_ratio ? candidate.bar_ratio.toString() : "0.0",
  percentage:
    candidate && candidate.percentage ? candidate.percentage.toString() : "0.0",
  angle: candidate && candidate.angle ? candidate.angle.toString() : "0.0",
});

export const normalizeAgent = (agent) => ({
  ...agent,
  id: agent && agent.id ? agent.id.toString() : "0",
  name: agent && agent.name ? agent.name : "Unknown",
  msisdn: agent && agent.msisdn ? agent.msisdn.toString() : "+000000000",
  pin: agent && agent.pin ? agent.pin.toString() : "0000",
  constituency:
    agent && agent.constituency
      ? normalizeConstituency(agent.constituency)
      : normalizeConstituency({}),
  poll: agent && agent.poll ? normalizePoll(agent.poll) : normalizePoll({}),
});

export const normalizeUser = (user) => ({
  ...user,
  id: user && user.id ? user.id.toString() : "0",
  name: user && user.name ? user.name : "Unknown",
  email: user && user.email ? user.email : "election@code.arbeitet.com",
  msisdn: user && user.msisdn ? user.msisdn.toString() : "+000000000",
  password: PASS,
  level: user && user.level ? user.level.toString() : "U",
  year: user && user.year ? user.year.toString() : "U",
  region:
    user && user.region ? normalizeRegion(user.region) : normalizeRegion({}),
});

export const normalizeApprove = (approve) => ({
  ...approve,
  id: approve && approve.id ? approve.id.toString() : "",
  message: approve && approve.message ? approve.message : "No Message",
  constituency:
    approve && approve.constituency
      ? normalizeConstituency(approve.constituency)
      : normalizeConstituency({}),
  region:
    approve && approve.region
      ? normalizeRegion(approve.region)
      : normalizeRegion({}),
  poll: normalizePoll(approve.poll),
  agent:
    approve && approve.agent
      ? normalizeAgent(approve.agent)
      : normalizeAgent({}),
  is_approved: !!(
    approve &&
    approve.is_approved &&
    approve.is_approved.toString().trim().toLowerCase() === "y"
  ),
  year: approve && approve.year ? approve.year.toString() : "",
  type: approve && approve.type ? approve.type : "",
  msisdn: approve && approve.msisdn ? approve.msisdn.toString() : "+000000000",
  posted_ts: approve && approve.posted_ts ? approve.posted_ts : "",
  status: approve && approve.status ? approve.status : "D",
});

export const normalizeNationalAnalysis = (nationalAnalysis) => ({
  ...nationalAnalysis,
  id:
    nationalAnalysis && nationalAnalysis.id
      ? nationalAnalysis.id.toString()
      : "",
  votes:
    nationalAnalysis && nationalAnalysis.votes
      ? nationalAnalysis.votes.toString()
      : "0",
  party:
    nationalAnalysis && nationalAnalysis.party
      ? normalizeParty(nationalAnalysis.party)
      : normalizeParty({}),
  year:
    nationalAnalysis && nationalAnalysis.year
      ? nationalAnalysis.year.toString()
      : "",
  type: nationalAnalysis && nationalAnalysis.type ? nationalAnalysis.type : "",
  percentage:
    nationalAnalysis && nationalAnalysis.percentage
      ? nationalAnalysis.percentage.toString()
      : "0.0",
  angle:
    nationalAnalysis && nationalAnalysis.angle
      ? nationalAnalysis.angle.toString()
      : "0.0",
  bar:
    nationalAnalysis && nationalAnalysis.bar
      ? nationalAnalysis.bar.toString()
      : "0.0",
});

export const normalizeRegionalAnalysis = (regionalAnalysis) => ({
  ...regionalAnalysis,
  id:
    regionalAnalysis && regionalAnalysis.id
      ? regionalAnalysis.id.toString()
      : "0",
  votes:
    regionalAnalysis && regionalAnalysis.votes
      ? regionalAnalysis.votes.toString()
      : "0",
  party:
    regionalAnalysis && regionalAnalysis.party
      ? normalizeParty(regionalAnalysis.party)
      : normalizeParty({}),
  region: normalizeRegion(regionalAnalysis.region),
  year:
    regionalAnalysis && regionalAnalysis.year
      ? regionalAnalysis.year.toString()
      : "",
  type: regionalAnalysis && regionalAnalysis.type ? regionalAnalysis.type : "",
  percentage:
    regionalAnalysis && regionalAnalysis.percentage
      ? regionalAnalysis.percentage.toString()
      : "0.0",
  angle:
    regionalAnalysis && regionalAnalysis.angle
      ? regionalAnalysis.angle.toString()
      : "0.0",
  bar:
    regionalAnalysis && regionalAnalysis.bar
      ? regionalAnalysis.bar.toString()
      : "0.0",
  status:
    regionalAnalysis && regionalAnalysis.status ? regionalAnalysis.status : "",
});

export const normalizeParentConstituency = (parentConstituency) => ({
  ...parentConstituency,
  id:
    parentConstituency && parentConstituency.id
      ? parentConstituency.id.toString()
      : "0",
  name:
    parentConstituency && parentConstituency.name
      ? parentConstituency.name
      : "",
  region:
    parentConstituency && parentConstituency.region
      ? normalizeRegion(parentConstituency.region)
      : normalizeRegion({}),
});

export const normalizeApproves = (apporoves) =>
  apporoves && apporoves.length
    ? apporoves.map((approve) => normalizeApprove(approve))
    : [];

export const normalizeCandidates = (candidates) =>
  candidates && candidates.length
    ? candidates
        .map((candidate) => normalizeCandidate(candidate))
        .sort((a, b) => sort(a, b))
    : [];

export const normalizeConstituencies = (constituencies) =>
  constituencies && constituencies.length
    ? constituencies
        .map((constituency) => normalizeConstituency(constituency))
        .sort((a, b) => sort(a, b))
    : [];

export const normalizeAllNationalAnalysis = (allNationalAnalysis) =>
  allNationalAnalysis && allNationalAnalysis.length
    ? allNationalAnalysis
        .map((nationalAnalysis) => normalizeNationalAnalysis(nationalAnalysis))
        .sort((a, b) => sort(a.party, b.party))
    : [];

export const normalizeAllRegionalAnalysis = (allRegionalAnalysis) =>
  allRegionalAnalysis && allRegionalAnalysis.length
    ? allRegionalAnalysis
        .map((regionalAnalysis) => normalizeRegionalAnalysis(regionalAnalysis))
        .sort((a, b) => sort(a.region, b.region))
    : [];

export const normalizeParentConstituencies = (parentConstituencies) =>
  parentConstituencies && parentConstituencies.length
    ? parentConstituencies
        .map((parentConstituency) =>
          normalizeParentConstituency(parentConstituency)
        )
        .sort((a, b) => sort(a, b))
    : [];

export const normalizeParties = (parties) =>
  parties && parties.length
    ? parties.map((party) => normalizeParty(party)).sort((a, b) => sort(a, b))
    : [];

export const normalizeRegions = (regions) =>
  regions && regions.length
    ? regions
        .map((region) => normalizeRegion(region))
        .sort((a, b) => sort(a, b))
    : [];

export const normalizePolls = (polls) =>
  polls && polls.length
    ? polls
        .map((poll) => normalizePoll(poll))
        .sort((a, b) => sort(a.constituency, b.constituency))
    : [];

export const normalizeAgents = (agents) =>
  agents && agents.length
    ? agents.map((agent) => normalizeAgent(agent)).sort((a, b) => sort(a, b))
    : [];

export const normalizeUsers = (users) =>
  users && users.length
    ? users.map((user) => normalizeUser(user)).sort((a, b) => sort(a, b))
    : [];
