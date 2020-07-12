import Elm from "./Main.elm";
import { getConstituencies, addConstituency } from "./api/constituencies";
import { getCandidates, addCandidate } from "./api/candidates";
import { getParties, addParty } from "./api/parties";
import { getPolls, addPoll } from "./api/polls";

// init the elm app
function create() {
  /* eslint-disable */
  console.log("Loaded!");

  // init and show the app
  const node = document.getElementById("app");
  const app = Elm.Elm.Main.init({ node, flags: "" + Date.now() });

  const handlePortMsg = ({ action, payload }) => {
    switch (action) {
      case "FetchCandidates": {
        console.log("Fetching candidates");
        getCandidates({ app, payload });
        break;
      }
      case "FetchConstituencies": {
        console.log("Fetching constituencies");
        getConstituencies({ app, payload });
        break;
      }
      case "FetchPolls": {
        console.log("Fetching polls");
        getPolls({ app, payload });
        break;
      }
      case "FetchParties": {
        console.log("Fetching parties");
        getParties({ app, payload });
        break;
      }
      case "InitApp": {
        console.log("Init App");
        break;
      }
      default:
        throw new Error(`Received unknown message ${action} from Elm.`);
    }
  };

  app.ports.msgForJs.subscribe(handlePortMsg);
}

create();
