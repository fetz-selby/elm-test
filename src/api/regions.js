const addRegion = async ({ service, region }) =>
  await service.service("regions").create(region);

const getRegions = async ({ service }) =>
  await service.service("regions").find();

const updateRegion = async ({ service, region }) =>
  await service.service("regions").update(0, region);

const deleteRegion = async ({ service, id }) =>
  await service.service("regions").remove(id);

export { getRegions, addRegion, updateRegion, deleteRegion };
