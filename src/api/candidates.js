import { URL } from "../constants";

const addCandidate = ({ service, app, payload }) => {};

const getCandidates = async ({ service, payload }) => {
  const { year, constituencyId } = payload;
  if (year) {
    return await service.service("candidates").find({ query: { year } });
  }

  return await service
    .service("candidates")
    .find({ query: { constituencyId } });
};

export { addCandidate, getCandidates };
