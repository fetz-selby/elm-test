import Elm from "./Main.elm";
import { getConstituencies, addConstituency } from "./api/constituencies";
import { getCandidates, addCandidate } from "./api/candidates";
import { getParties, addParty } from "./api/parties";
import { getPolls, addPoll } from "./api/polls";
import { getRegions } from "./api/regions";
import { getParentConstituencies } from "./api/parentConstituencies";
import { flatenConstituenciesWithRegionIdIncluded } from "./api/helper";
import io from "socket.io-client";
import feathers from "@feathersjs/client";

// init the elm app
async function create() {
  /* eslint-disable */
  console.log("Loaded!");

  // init and show the app
  let [regions, parentConstituencies] = [[], []];
  let setup = { constituencyId: "", regionId: "", year: "2016" };

  const node = document.getElementById("app");
  const app = Elm.Elm.Main.init({ node, flags: "" + Date.now() });

  const handlePortMsg = async ({ action, payload }) => {
    const socket = io("http://localhost:5002");
    // @feathersjs/client is exposed as the `feathers` global.
    const service = feathers();
    const { constituencyId, regionId, year } = setup;

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
            constituencies: flatenConstituenciesWithRegionIdIncluded(
              parentConstituencies,
              constituencies
            ),
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

        app.ports.msgForElm.send({
          type: "RegionsLoaded",
          payload: {
            regions,
          },
        });
        break;
      }

      case "InitRegions": {
        regions = await getRegions({ service, app });

        app.ports.msgForElm.send({
          type: "RegionsLoaded",
          payload: { regions },
        });

        break;
      }

      case "InitConstituencies": {
        app.ports.msgForElm.send({
          type: "ConstituenciesLoaded",
          payload: null,
        });

        break;
      }

      case "InitCandidates": {
        app.ports.msgForElm.send({
          type: "CandidatesLoaded",
          payload: null,
        });

        break;
      }

      case "InitParties": {
        app.ports.msgForElm.send({
          type: "PartiesLoaded",
          payload: null,
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
        app.ports.msgForElm.send({
          type: "ApprovesLoaded",
          payload: null,
        });

        break;
      }

      case "InitSummary": {
        app.ports.msgForElm.send({
          type: "SummarysLoaded",
          payload: null,
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
