const addCandidate = async ({ service, candidate }) =>
  await service.service("candidates").create(candidate);

const getCandidates = async ({ service, year, regionId }) =>
  await service.service("candidates").find({ query: { year, regionId } });

export { addCandidate, getCandidates };
