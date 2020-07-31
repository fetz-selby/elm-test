import Elm from "./Main.elm";
import { getConstituencies, addConstituency } from "./api/constituencies";
import { getCandidates, addCandidate } from "./api/candidates";
import { getParties, addParty } from "./api/parties";
import { getPolls, addPoll } from "./api/polls";
import { getRegions } from "./api/regions";
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
} from "./api/helper";
import io from "socket.io-client";
import feathers from "@feathersjs/client";

// init the elm app
async function create() {
  /* eslint-disable */
  console.log("Loaded!");

  // init and show the app
  let [regions, parentConstituencies] = [[], []];
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
        regions = await getRegions({ service, app });
        parentConstituencies = await getParentConstituencies({ service });

        break;
      }

      case "InitRegions": {
        regions = role === ADMIN ? await getRegions({ service, app }) : [];

        app.ports.msgForElm.send({
          type: "RegionsLoaded",
          payload: { regionData: { regions } },
        });

        break;
      }

      case "InitConstituencies": {
        const constituencies =
          role === ADMIN
            ? await getConstituencies({
                service,
                year,
              })
            : [];

        const parentConstituencies = await getParentConstituencies({ service });
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
        const candidates =
          role === ADMIN
            ? await getCandidates({ service, payload: { year } })
            : await getCandidates({ service, payload: { constituencyId } });
        const constituencies = await getConstituencies({ service, year });
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

      case "InitParties": {
        const parties = await getParties({ service });

        app.ports.msgForElm.send({
          type: "PartiesLoaded",
          payload: { partyData: { parties: normalizeParties(parties) } },
        });

        break;
      }

      case "InitPolls": {
        app.ports.msgForElm.send({
          type: "PollsLoaded",
          payload: null,
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

      default:
        throw new Error(`Received unknown message ${action} from Elm.`);
    }
  };

  app.ports.msgForJs.subscribe(handlePortMsg);
}

create();
