import { URL } from "../constants";

const addParty = async ({ app, payload }) => {};

const getParties = async ({ service }) =>
  await service.service("parties").find({ query: { year: payload.year } });

export { addParty, getParties };
