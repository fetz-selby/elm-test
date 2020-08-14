import Elm from "./Main.elm";
import { getAgents, addAgent } from "./api/agents";
import { getUsers, addUser } from "./api/users";
import { getConstituencies, addConstituency } from "./api/constituencies";
import { getCandidates, addCandidate } from "./api/candidates";
import { getParties, addParty } from "./api/parties";
import { getPolls, addPoll } from "./api/polls";
import { getRegions, deleteRegion, addRegion } from "./api/regions";
import {
  getParentConstituencies,
  addParentConstituency,
} from "./api/parentConstituencies";
import { getApproves } from "./api/approves";
import {
  getNationalAnalysis,
  addNationalAnalysis,
} from "./api/nationalAnalysis";
import {
  getRegionalAnalysis,
  addRegionalAnalysis,
} from "./api/regionalAnalysis";
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
  normalizeUser,
  normalizeAgent,
  normalizeRegion,
  normalizeConstituency,
  normalizeCandidate,
  normalizeParty,
  normalizePoll,
  normalizeParentConstituency,
  normalizeRegionalAnalysis,
  normalizeNationalAnalysis,
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
    const { regionId, year, role } = setup;
    const { ADMIN, USER } = ROLE;

    service.configure(feathers.socketio(socket));
    service.configure(feathers.authentication());
    console.log("action, ", action);

    switch (action) {
      case "InitApp": {
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

      case "InitParentConstituencies": {
        const regions = await getRegions({ service });
        const parentConstituencies = await getParentConstituencies({
          service,
          regionId,
        });

        app.ports.msgForElm.send({
          type: "ParentConstituenciesLoaded",
          payload: {
            parentConstituencyData: {
              parentConstituencies: normalizeParentConstituencies(
                parentConstituencies
              ),
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
        const addAgentResp = await addAgent({ service, agent });
        console.log("[AddAgent], ", addAgentResp);
        // const addAgentResp = await addAgent({ service, agent });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveCandidate": {
        const candidate = { ...payload, year };
        const addCandidateResp = await addCandidate({ service, candidate });
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveConstituency": {
        const constituency = { ...payload, year };
        const addConstituencyResp = await addConstituency({
          service,
          constituency,
        });
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveNationalSummary": {
        const nationalAnalysis = { ...payload, year };
        console.log("NationalAnalysis,", nationalAnalysis);
        const addNationalAnalysisResp = await addNationalAnalysis({
          service,
          nationalAnalysis,
        });

        break;
      }

      case "SaveRegionalSummary": {
        const regionalAnalysis = { ...payload, region_id: regionId, year };
        console.log("RegionalAnalysis,", regionalAnalysis);
        const addRegionalAnalysisResp = await addRegionalAnalysis({
          service,
          regionalAnalysis,
        });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveParty": {
        const party = { ...payload };
        const addPartyResp = await addParty({ service, party });
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveRegion": {
        const region = { ...payload };
        const addRegionResp = await addRegion({ service, region });
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SavePoll": {
        const poll = { ...payload, year };
        const addPollResp = await addPoll({ service, poll });

        break;
      }

      case "SaveParentConstituency": {
        const parentConstituency = { ...payload, region_id: regionId };

        const addParentConstituencyResp = await addParentConstituency({
          service,
          parentConstituency,
        });
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

    service.service("agents").on("created", (agent, c) => {
      app.ports.msgForElm.send({
        type: "OneAgentAdded",
        payload: normalizeAgent(agent),
      });
    });

    service.service("users").on("created", (user, c) => {
      app.ports.msgForElm.send({
        type: "OneUserAdded",
        payload: normalizeUser(user),
      });
    });

    service.service("regions").on("created", (region, c) => {
      app.ports.msgForElm.send({
        type: "OneRegionAdded",
        payload: normalizeRegion(region),
      });
    });

    service.service("constituencies").on("created", (constituency, c) => {
      app.ports.msgForElm.send({
        type: "OneConstituencyAdd",
        payload: normalizeConstituency(constituency),
      });
    });

    service.service("approve_list").on("created", (d, c) => {});

    service.service("candidates").on("created", (candidate, c) => {
      app.ports.msgForElm.send({
        type: "OneCandidateAdded",
        payload: normalizeCandidate(candidate),
      });
    });

    service
      .service("national_analysis")
      .on("created", (nationalAnalysis, c) => {
        app.ports.msgForElm.send({
          type: "OneNationalAnalysisAdded",
          payload: normalizeNationalAnalysis(nationalAnalysis),
        });
      });

    service
      .service("parent_constituencies")
      .on("created", (parentConstituency, c) => {
        app.ports.msgForElm.send({
          type: "OneParentConstituencyAdd",
          payload: normalizeParentConstituency(parentConstituency),
        });
      });

    service.service("parties").on("created", (party, c) => {
      app.ports.msgForElm.send({
        type: "OnePartyAdded",
        payload: normalizeParty(party),
      });
    });

    service.service("polls").on("created", (poll, c) => {
      app.ports.msgForElm.send({
        type: "OnePollAdded",
        payload: normalizePoll(poll),
      });
    });

    service
      .service("regional_analysis")
      .on("created", (regionalAnalysis, c) => {
        app.ports.msgForElm.send({
          type: "OneRegionalAnalysisAdded",
          payload: normalizeRegionalAnalysis(regionalAnalysis),
        });
      });

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
