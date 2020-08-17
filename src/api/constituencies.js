const addConstituency = async ({ service, constituency }) =>
  await service.service("constituencies").create(constituency);

const updateConstituency = async ({ service, constituency }) =>
  await service.service("constituencies").update(constituency.id, constituency);

const getConstituencies = async ({ service, regionId, year }) =>
  await service.service("constituencies").find({ query: { year, regionId } });

export { addConstituency, updateConstituency, getConstituencies };
