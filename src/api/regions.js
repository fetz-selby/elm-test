import { URL } from "../constants";

const getRegions = async ({ service }) =>
  await service.service("regions").find();

export { getRegions };
