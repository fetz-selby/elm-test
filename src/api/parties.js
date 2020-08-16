const addParty = async ({ service, party }) =>
  await service.service("parties").create(party);

const updateParty = async ({ service, party }) =>
  await service.service("parties").update(0, party);

const getParties = async ({ service }) =>
  await service.service("parties").find();

export { addParty, updateParty, getParties };
