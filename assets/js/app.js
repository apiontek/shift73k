// We import the main SCSS file, which performs all other SCSS imports,
// and which vite.js will preprocess with sass.
import '../css/app.scss'

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import 'phoenix_html'

// import Socket for Phoenix Channels
import { Socket } from "phoenix";
// import topbar for load progress in live reloading / liveview
import topbar from "topbar";
// import LiveSocket for LiveView
import { LiveSocket } from "phoenix_live_view";


// Bootstrap v5 js imports
import 'bootstrap/js/dist/alert';
import 'bootstrap/js/dist/collapse';
import 'bootstrap/js/dist/dropdown';
// Bootstrap helpers
import './_hamburger-helper';
import "./_form-validity";
// Bootstrap-liveview helpers
import { AlertRemover } from "./_alert-remover";
import { BsModal } from "./_bs_modal";
import { BsCollapse } from "./_bs_collapse";

// LiveSocket setup
let Hooks = {};
Hooks.AlertRemover = AlertRemover;
Hooks.BsModal = BsModal;
Hooks.BsCollapse = BsCollapse;
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
