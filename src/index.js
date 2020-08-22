import Elm from "./Main.elm";
import { getAgents, addAgent, updateAgent } from "./api/agents";
import { getSeats } from "./api/seats";

import { getLogin } from "./api/login";
import { getUsers, addUser, updateUser } from "./api/users";
import {
  getConstituencies,
  addConstituency,
  updateConstituency,
} from "./api/constituencies";
import { getCandidates, addCandidate, updateCandidate } from "./api/candidates";
import { getParties, addParty, updateParty } from "./api/parties";
import { getPolls, addPoll, updatePoll } from "./api/polls";
import {
  getRegions,
  deleteRegion,
  addRegion,
  updateRegion,
} from "./api/regions";
import {
  getParentConstituencies,
  addParentConstituency,
  updateParentConstituency,
} from "./api/parentConstituencies";
import { getApproves, updateApprove, removeApprove } from "./api/approves";
import {
  getNationalAnalysis,
  addNationalAnalysis,
  updateNationalAnalysis,
} from "./api/nationalAnalysis";
import {
  getRegionalAnalysis,
  addRegionalAnalysis,
  updateRegionalAnalysis,
} from "./api/regionalAnalysis";
import { ROLE, URL } from "./constants";
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
  normalizeApprove,
  normalizeLoginUser,
  normalizeSeats,
  PASS,
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
    regionId: "1",
    year: "2016",
    level: "U",
  };

  const node = document.getElementById("app");
  const app = Elm.Elm.Main.init({ node, flags: "" + Date.now() });

  const handlePortMsg = async ({ action, payload }) => {
    const socket = io(URL.BASE_URL + URL.PORT);
    // @feathersjs/client is exposed as the `feathers` global.
    const service = feathers();
    const { regionId, year, level } = setup;
    const { ADMIN, USER } = ROLE;

    service.configure(feathers.socketio(socket));
    service.configure(feathers.authentication());
    console.log("action, ", action);

    switch (action) {
      case "FetchUser": {
        console.log("credentials, ", payload);
        const { email, password } = payload;
        try {
          const user = await getLogin({ service, email, password });
          if (user.error) {
            console.log("Error occurred");
            app.ports.msgForElm.send({
              type: "LoginError",
              payload: {},
            });
          } else {
            const { year, region_id, level } = user;
            setup = {
              year,
              regionId: region_id,
              level,
            };
            console.log("Login success");
            app.ports.msgForElm.send({
              type: "LoginLoaded",
              payload: { loginUser: normalizeLoginUser(user) },
            });
          }
        } catch (err) {
          console.log("Login Error");
        }
        break;
      }

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

      case "InitSeats": {
        const seats = await getSeats({ service, year, regionId });
        app.ports.msgForElm.send({
          type: "SeatsLoaded",
          payload: { seatData: { seats: normalizeSeats(seats) } },
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
        const regionalAnalysis = await getRegionalAnalysis({
          service,
          year,
          regionId,
        });
        const regions = [];
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
        const agent = { ...payload, year, regionId };
        const addAgentResp = await addAgent({ service, agent });
        console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveCandidate": {
        const candidate = { ...payload, year, regionId };
        const addCandidateResp = await addCandidate({ service, candidate });
        // const addCandidateResp = await addCandidate({ service, candidate });
        // console.log("[AddAgent], ", addAgentResp);

        break;
      }

      case "SaveConstituency": {
        const constituency = { ...payload, year, regionId };
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
        const poll = { ...payload, year, regionId };
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

      case "UpdateRegion": {
        const region = { ...payload };
        const updateRegionResp = await updateRegion({ service, region });
        break;
      }

      case "UpdateUser": {
        const user = { ...payload };

        if (user.password === PASS) {
          delete user.password;
        }

        const updateUserResp = await updateUser({ service, user });
        console.log("user, ", user);
        break;
      }

      case "UpdateAgent": {
        const agent = { ...payload, year, regionId };
        const updateAgentResp = await updateAgent({ service, agent });
        console.log("agent, ", agent);

        break;
      }

      case "UpdateConstituency": {
        const constituency = { ...payload, year, regionId };
        const updateConstituencyResp = await updateConstituency({
          service,
          constituency,
        });
        console.log("constituency, ", constituency);

        break;
      }

      case "UpdateCandidate": {
        const candidate = { ...payload, year, regionId };
        const updateCandidateResp = await updateCandidate({
          service,
          candidate,
        });
        console.log("candidate, ", candidate);

        break;
      }

      case "UpdateParty": {
        const party = { ...payload };
        const updatePartyResp = await updateParty({ service, party });
        console.log("party, ", party);

        break;
      }

      case "UpdatePoll": {
        const poll = { ...payload, year, regionId };
        const updatePollResp = await updatePoll({ service, poll });
        console.log("poll, ", poll);

        break;
      }

      case "UpdateParentConstituency": {
        const parentConstituency = { ...payload, region_id: regionId };
        const updateParentConstituencyResp = await updateParentConstituency({
          service,
          parentConstituency,
        });
        console.log("parentConstituency, ", parentConstituency);

        break;
      }

      case "UpdateRegionalSummary": {
        const regionalAnalysis = { ...payload, region_id: regionId, year };
        const updateRegionalAnalysisResp = await updateRegionalAnalysis({
          service,
          regionalAnalysis,
        });
        console.log("regional, ", regionalAnalysis);

        break;
      }

      case "UpdateNationalSummary": {
        const nationalAnalysis = { ...payload, year };
        const updateNationalAnalysisResp = await updateNationalAnalysis({
          service,
          nationalAnalysis,
        });
        console.log("national, ", nationalAnalysis);

        break;
      }

      case "UpdateApprove": {
        const approve = { ...payload, year, regionId };
        const updateApproveResp = await updateApprove({
          service,
          approve,
        });
        console.log("approve, ", approve);

        break;
      }

      case "DeleteRegion": {
        console.log("Delete ID, ", payload);
        const deleteResp = await deleteRegion({ service, id: payload });
        console.log("resp, ", deleteResp);

        break;
      }

      case "DeleteApprove": {
        console.log("[Delete Id], ", payload);
        const approveId = await removeApprove({ service, id: payload });

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

    service.service("approve_list").on("removed", (approve, c) => {
      console.log("[in remove], ", approve);
      app.ports.msgForElm.send({
        type: "OneApproveUpdated",
        payload: normalizeApprove(approve),
      });
    });

    service.service("candidates").on("removed", (d, c) => {});

    service.service("national_analysis").on("removed", (d, c) => {});

    service.service("parent_constituencies").on("removed", (d, c) => {});

    service.service("parties").on("removed", (d, c) => {});

    service.service("regional_analysis").on("removed", (d, c) => {});

    // When a model is created

    service.service("agents").on("created", (agent, c) => {
      if (agent.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneAgentAdded",
          payload: normalizeAgent(agent),
        });
      }
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
      if (constituency.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneConstituencyAdd",
          payload: normalizeConstituency(constituency),
        });
      }
    });

    service.service("approve_list").on("created", (d, c) => {});

    service.service("candidates").on("created", (candidate, c) => {
      if (candidate.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneCandidateAdded",
          payload: normalizeCandidate(candidate),
        });
      }
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
        if (parentConstituency.regionId === regionId) {
          app.ports.msgForElm.send({
            type: "OneParentConstituencyAdd",
            payload: normalizeParentConstituency(parentConstituency),
          });
        }
      });

    service.service("parties").on("created", (party, c) => {
      app.ports.msgForElm.send({
        type: "OnePartyAdded",
        payload: normalizeParty(party),
      });
    });

    service.service("polls").on("created", (poll, c) => {
      if (poll.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OnePollAdded",
          payload: normalizePoll(poll),
        });
      }
    });

    service
      .service("regional_analysis")
      .on("created", (regionalAnalysis, c) => {
        if (regionalAnalysis.regionId === regionId) {
          app.ports.msgForElm.send({
            type: "OneRegionalAnalysisAdded",
            payload: normalizeRegionalAnalysis(regionalAnalysis),
          });
        }
      });

    // When a model is updated
    service.service("agents").on("updated", (agent, c) => {
      if (agent.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneAgentUpdated",
          payload: normalizeAgent(agent),
        });
      }
    });

    service.service("regions").on("updated", (region, c) => {
      app.ports.msgForElm.send({
        type: "OneRegionUpdated",
        payload: normalizeRegion(region),
      });
    });

    service.service("users").on("updated", (user, c) => {
      app.ports.msgForElm.send({
        type: "OneUserUpdated",
        payload: normalizeUser(user),
      });
    });

    service.service("constituencies").on("updated", (constituency, c) => {
      if (constituency.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneConstituencyUpdated",
          payload: normalizeConstituency(constituency),
        });
      }
    });

    service.service("approve_list").on("updated", (approve, c) => {
      if (approve.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneApproveUpdated",
          payload: normalizeApprove(approve),
        });
      }
    });

    service.service("candidates").on("updated", (candidate, c) => {
      if (candidate.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OneCandidateUpdated",
          payload: normalizeCandidate(candidate),
        });
      }
    });

    service.service("polls").on("updated", (poll, c) => {
      if (poll.regionId === regionId) {
        app.ports.msgForElm.send({
          type: "OnePollUpdated",
          payload: normalizePoll(poll),
        });
      }
    });

    service.service("national_analysis").on("updated", (national, c) => {
      app.ports.msgForElm.send({
        type: "OneNationalAnalysisUpdated",
        payload: normalizeNationalAnalysis(national),
      });
    });

    service
      .service("parent_constituencies")
      .on("updated", (parentConstituency, c) => {
        if (parentConstituency.regionId === regionId) {
          app.ports.msgForElm.send({
            type: "OneParentConstituencyUpdated",
            payload: normalizeParentConstituency(parentConstituency),
          });
        }
      });

    service.service("parties").on("updated", (party, c) => {
      app.ports.msgForElm.send({
        type: "OnePartyUpdated",
        payload: normalizeParty(party),
      });
    });

    service.service("regional_analysis").on("updated", (regional, c) => {
      app.ports.msgForElm.send({
        type: "OneRegionalAnalysisUpdated",
        payload: normalizeRegionalAnalysis(regional),
      });
    });
  };

  app.ports.msgForJs.subscribe(handlePortMsg);
}

create();
