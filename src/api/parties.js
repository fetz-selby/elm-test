const addParty = async ({ service, party }) =>
  await service.service("parties").create(party);

const getParties = async ({ service }) =>
  await service.service("parties").find();

export { addParty, getParties };
