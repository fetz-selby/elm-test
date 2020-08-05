const addCandidate = ({ service, payload }) => {
  const candidate = {
    name: payload.name,
    partyId: payload.partyId,
    constituencyId: payload.constituencyId,
    year: payload.year,
    votes: payload.votes,
    avatarPath: payload.avatarPath,
  };

  service.service("candidates").create(candidate);
};

const getCandidates = async ({ service, payload }) => {
  const { year, constituencyId } = payload;
  if (year) {
    return await service.service("candidates").find({ query: { year } });
  }

  return await service
    .service("candidates")
    .find({ query: { constituencyId } });
};

export { addCandidate, getCandidates };
