const addConstituency = async ({ service, constituency }) =>
  await service.service("constituencies").create(constituency);

const getConstituencies = async ({ service, regionId, year }) =>
  await service.service("constituencies").find({ query: { year, regionId } });

export { addConstituency, getConstituencies };
