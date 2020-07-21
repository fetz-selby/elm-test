import { URL } from "../constants";

const addConstituency = async ({ app, payload }) => {};

const getConstituencies = async ({ service, app, payload }) =>
  await service
    .service("constituencies")
    .find({ query: { year: payload.year } });

export { addConstituency, getConstituencies };
