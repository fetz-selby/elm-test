const addParty = async ({ app, payload }) => {};

const getParties = async ({ service }) =>
  await service.service("parties").find();

export { addParty, getParties };
