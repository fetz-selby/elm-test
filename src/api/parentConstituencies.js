import { URL } from "../constants";

const getParentConstituencies = async ({ service }) =>
  await service.service("parent_constituencies").find();

export { getParentConstituencies };
