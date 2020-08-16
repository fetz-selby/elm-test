const addCandidate = async ({ service, candidate }) =>
  await service.service("candidates").create(candidate);

const updateCandidate = async ({ service, candidate }) =>
  await service.service("candidates").update(0, candidate);

const getCandidates = async ({ service, year, regionId }) =>
  await service.service("candidates").find({ query: { year, regionId } });

export { addCandidate, updateCandidate, getCandidates };
