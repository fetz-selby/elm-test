import { URL } from "../constants";

const addCandidate = ({ service, app, payload }) => {};

const getCandidates = async ({ service, app, payload }) => {
  const { year } = payload;
  const candidates = await service
    .service("candidates")
    .find({ query: { year } });

  console.log("candidates, ", candidates);
  // app.main.ports.msgForElm.send({
  //   type: "Candidates",
  //   payload: { candidates }
  // });
};

export { addCandidate, getCandidates };
