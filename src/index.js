import Elm from "./Main.elm";

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
        break;
      }
      case "FetchConstituencies": {
        console.log("Fetching constituencies");
        break;
      }
      case "FetchPolls": {
        console.log("Fetching polls");
        break;
      }
      case "SelectedLocation":
        break;
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
