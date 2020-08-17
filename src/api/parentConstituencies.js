const addParentConstituency = async ({ service, parentConstituency }) =>
  await service.service("parent_constituencies").create(parentConstituency);

const updateParentConstituency = async ({ service, parentConstituency }) =>
  await service
    .service("parent_constituencies")
    .update(parentConstituency.id, parentConstituency);

const getParentConstituencies = async ({ service, regionId }) =>
  await service.service("parent_constituencies").find({ query: { regionId } });

export {
  getParentConstituencies,
  updateParentConstituency,
  addParentConstituency,
};
