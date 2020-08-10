import Elm from "./Main.elm";
import { getAgents, addAgent } from "./api/agents";
import { getUsers, addUser } from "./api/users";
import { getConstituencies, addConstituency } from "./api/constituencies";
import { getCandidates, addCandidate } from "./api/candidates";
import { getParties, addParty } from "./api/parties";
import { getPolls, addPoll } from "./api/polls";
import { getRegions, deleteRegion } from "./api/regions";
import { getParentConstituencies } from "./api/parentConstituencies";
import { getApproves } from "./api/approves";
import { getNationalAnalysis } from "./api/nationalAnalysis";
import { getRegionalAnalysis } from "./api/regionalAnalysis";
import { ROLE } from "./constants";
import {
  flatenConstituenciesWithRegionIdIncluded,
  normalizeConstituencies,
  normalizeCandidates,
  normalizeApproves,
  normalizeAllNationalAnalysis,
  normalizeAllRegionalAnalysis,
  normalizeParentConstituencies,
  normalizeParties,
  normalizeRegions,
  normalizePolls,
  normalizeAgents,
  normalizeUsers,
} from "./api/helper";
import io from "socket.io-client";
import feathers from "@feathersjs/client";

// init the elm app
async function create() {
  /* eslint-disable */
  console.log("Loaded!");

  // init and show the app
  // let [regions, parentConstituencies] = [[], []];
  let setup = {
    constituencyId: "",
    regionId: "1",
    year: "2016",
    role: "admin",
  };

  const node = document.getElementById("app");
  const app = Elm.Elm.Main.init({ node, flags: "" + Date.now() });

  const handlePortMsg = async ({ action, payload }) => {
    const socket = io("http://localhost:5002");
    // @feathersjs/client is exposed as the `feathers` global.
    const service = feathers();
    const { constituencyId, regionId, year, role } = setup;
    const { ADMIN, USER } = ROLE;

    service.configure(feathers.socketio(socket));
    service.configure(feathers.authentication());
    console.log("action, ", action);

    switch (action) {
      case "FetchCandidates": {
        const candidates = getCandidates({
          service,
          payload: { year, constituencyId },
        });
        app.main.ports.msgForElm.send({
          type: "CandidatesLoaded",
          payload: {
            candidates,
          },
        });
        break;
      }

      case "FetchConstituencies": {
        const constituencies = await getConstituencies({ app, payload });

        app.main.ports.msgForElm.send({
          type: "ConstituenciesLoaded",
          payload: {
            constituencies,
          },
        });

        break;
      }

      case "FetchPolls": {
        console.log("Fetching polls");
        getPolls({ app, payload });
        break;
      }

      case "FetchParties": {
        console.log("Fetching parties");
        const parties = await getParties({ service });
        app.main.ports.msgForElm.send({
          type: "PartiesLoaded",
          payload: {
            parties,
          },
        });
        break;
      }

      case "InitApp": {
        const regions = await getRegions({ service, app });
        const parentConstituencies = await getParentConstituencies({ service });

        break;
      }

      case "InitAgents": {
        const agents = await getAgents({ service, year, regionId });
        const constituencies = await getConstituencies({
          service,
          year,
          regionId,
        });
        const polls = await getPolls({ service, year, regionId });

        app.ports.msgForElm.send({
          type: "AgentsLoaded",
          payload: {
            agentData: {
              agents: normalizeAgents(agents),
              constituencies: normalizeConstituencies(constituencies),
              polls: normalizePolls(polls),
            },
          },
        });

        break;
      }

      case "InitRegions": {
        const regions = await getRegions({ service });

        app.ports.msgForElm.send({
          type: "RegionsLoaded",
          payload: { regionData: { regions: normalizeRegions(regions) } },
        });

        break;
      }

      case "InitConstituencies": {
        const constituencies = await getConstituencies({
          service,
          year,
          regionId,
        });

        const parentConstituencies = await getParentConstituencies({
          service,
          regionId,
        });
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "ConstituenciesLoaded",
          payload: {
            constituencyData: {
              constituencies: normalizeConstituencies(constituencies),
              parentConstituencies: normalizeParentConstituencies(
                parentConstituencies
              ),
              parties: normalizeParties(parties),
            },
          },
        });

        break;
      }

      case "InitCandidates": {
        const candidates = await getCandidates({ service, year, regionId });
        const constituencies = await getConstituencies({
          service,
          year,
          regionId,
        });
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "CandidatesLoaded",
          payload: {
            candidateData: {
              candidates: normalizeCandidates(candidates),
              constituencies: normalizeConstituencies(constituencies),
              parties: normalizeParties(parties),
            },
          },
        });

        break;
      }

      case "InitUsers": {
        const users = await getUsers({ service });
        const regions = await getRegions({ service });

        console.log("users, ", users);
        console.log("regions, ", regions);

        app.ports.msgForElm.send({
          type: "UsersLoaded",
          payload: {
            userData: {
              users: normalizeUsers(users),
              regions: normalizeRegions(regions),
            },
          },
        });

        break;
      }

      case "InitParties": {
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "PartiesLoaded",
          payload: { partyData: { parties: normalizeParties(parties) } },
        });

        break;
      }

      case "InitPolls": {
        const constituencies = await getConstituencies({
          service,
          year,
          regionId,
        });
        const polls = await getPolls({ service, year, regionId });

        app.ports.msgForElm.send({
          type: "PollsLoaded",
          payload: {
            pollData: {
              polls: normalizePolls(polls),
              constituencies: normalizeConstituencies(constituencies),
            },
          },
        });

        break;
      }

      case "InitApprove": {
        const approves = await getApproves({ service, year, regionId });
        app.ports.msgForElm.send({
          type: "ApprovesLoaded",
          payload: { approveData: { approves: normalizeApproves(approves) } },
        });

        break;
      }

      case "InitNationalSummary": {
        const nationalAnalysis = await getNationalAnalysis({ service, year });
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "NationalAnalysisLoaded",
          payload: {
            nationalAnalysisData: {
              nationalAnalysis: normalizeAllNationalAnalysis(nationalAnalysis),
              parties: normalizeParties(parties),
            },
          },
        });

        break;
      }

      case "InitRegionalSummary": {
        const regionalAnalysis = await getRegionalAnalysis({ service, year });
        const regions = await getRegions({ service });
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "RegionalAnalysisLoaded",
          payload: {
            regionalAnalysisData: {
              regionalAnalysis: normalizeAllRegionalAnalysis(regionalAnalysis),
              regions: normalizeRegions(regions),
              parties: normalizeParties(parties),
            },
          },
        });

        break;
      }

      case "SaveUser": {
        const user = payload;
        const addUserResp = await addUser({ service, user });
        console.log("[AddUser], ", addUserResp);

        break;
      }

      case "SaveAgent": {
        const agent = { ...payload, year };
        console.log("Agent,", agent);
        // const addAgentResp = await addAgent({ service, agent });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveCandidate": {
        const candidate = { ...payload, year };
        console.log("Candidate,", candidate);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveConstituency": {
        const constituency = { ...payload, year };
        console.log("Constituency,", constituency);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveNationalSummary": {
        const nationalAnalysis = { ...payload, year };
        console.log("NationalAnalysis,", nationalAnalysis);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveRegionalSummary": {
        const regionalAnalysis = { ...payload, year };
        console.log("RegionalAnalysis,", regionalAnalysis);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveParty": {
        const party = { ...payload, year };
        console.log("Party,", party);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SavePoll": {
        const poll = { ...payload, year };
        console.log("Poll,", poll);
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "UpdateApprove": {
        console.log("[Update Approve], ", payload);

        break;
      }

      case "UpdateCandidate": {
        console.log("[Update Candidate], ", payload);

        break;
      }

      case "DeleteRegion": {
        console.log("Delete ID, ", payload);
        const deleteResp = await deleteRegion({ service, id: payload });
        console.log("resp, ", deleteResp);

        break;
      }

      case "DeleteApprove": {
        console.log("[Approve Id], ", payload);

        break;
      }

      default:
        throw new Error(`Received unknown message ${action} from Elm.`);
    }

    // When a model is removed
    service.service("agents").on("removed", (d, c) => {
      console.log("agent removed");
    });
    service.service("regions").on("removed", (d, c) => {
      console.log("region removed");
    });

    service.service("constituencies").on("removed", (d, c) => {});

    service.service("approve_list").on("removed", (d, c) => {});

    service.service("candidates").on("removed", (d, c) => {});

    service.service("national_analysis").on("removed", (d, c) => {});

    service.service("parent_constituencies").on("removed", (d, c) => {});

    service.service("parties").on("removed", (d, c) => {});

    service.service("regional_analysis").on("removed", (d, c) => {});

    // When a model is created

    service.service("agents").on("created", (d, c) => {
      console.log("agent created");
    });

    service.service("users").on("created", (d, c) => {
      console.log("user created");
    });

    service.service("regions").on("created", (d, c) => {
      console.log("region created");
    });

    service.service("constituencies").on("created", (d, c) => {});

    service.service("approve_list").on("created", (d, c) => {});

    service.service("candidates").on("created", (d, c) => {});

    service.service("national_analysis").on("created", (d, c) => {});

    service.service("parent_constituencies").on("created", (d, c) => {});

    service.service("parties").on("created", (d, c) => {});

    service.service("regional_analysis").on("created", (d, c) => {});

    // When a model is updated
    service.service("agents").on("updated", (d, c) => {
      console.log("agent updated");
    });
    service.service("regions").on("updated", (d, c) => {
      console.log("region updated");
    });

    service.service("constituencies").on("updated", (d, c) => {});

    service.service("approve_list").on("updated", (d, c) => {});

    service.service("candidates").on("updated", (d, c) => {});

    service.service("national_analysis").on("updated", (d, c) => {});

    service.service("parent_constituencies").on("updated", (d, c) => {});

    service.service("parties").on("updated", (d, c) => {});

    service.service("regional_analysis").on("updated", (d, c) => {});
  };

  app.ports.msgForJs.subscribe(handlePortMsg);
}

create();
