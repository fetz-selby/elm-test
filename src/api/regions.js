const addRegion = ({ service, payload }) => {
  const region = {
    name: payload.name,
    seats: payload.seats,
  };

  service.service("regions").create(region);
};

const getRegions = async ({ service }) =>
  await service.service("regions").find();

const deleteRegion = async ({ service, id }) =>
  await service.service("regions").remove(id);

export { getRegions, addRegion, deleteRegion };
