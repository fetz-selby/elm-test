import { Elm } from "./Main.elm";
import {
  normalizeCars,
} from "./api/helper";

// init the elm app
async function create() {
  // init and show the app
 

  const node = document.getElementById("app");
  const app = Elm.Main.init({ node, flags: "" + Date.now() });


  const handlePortMsg = async ({ action, payload }) => {

    switch (action) {
      case "FetchCars": {
        fetch('https://boiling-chamber-77385.herokuapp.com/models')
          .then(function(response) {
            if (!response.ok) {
              throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
          })
          .then(function(response) {
            app.ports.msgForElm.send({
              type: "CarsLoaded",
              payload: { cars : normalizeCars(response) },
            });
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
