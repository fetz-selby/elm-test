import { URL } from "../constants";

const addConstituency = async ({ app, payload }) => {};

const getConstituencies = async ({ service, year }) =>
  await service.service("constituencies").find({ query: { year } });

export { addConstituency, getConstituencies };
