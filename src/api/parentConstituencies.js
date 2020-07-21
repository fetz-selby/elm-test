import { URL } from "../constants";

const addParentConstituency = async ({ app, payload }) => {};

const getParentConstituencies = async ({ service }) =>
  await service.service("parent_constituencies").find();

export { addParentConstituency, getParentConstituencies };
