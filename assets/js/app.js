// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// Import icons for sprite-loader
// navbar brand icon
import "../node_modules/bootstrap-icons/icons/calendar2-week.svg"; // brand
// menus etc
import "../node_modules/bootstrap-icons/icons/person-circle.svg"; // accounts menu
import "../node_modules/bootstrap-icons/icons/person-plus.svg"; // new user / register
import "../node_modules/bootstrap-icons/icons/door-open.svg"; // log in
import "../node_modules/bootstrap-icons/icons/door-closed.svg"; // log out
import "../node_modules/bootstrap-icons/icons/sliders.svg"; // new user / register
// forms etc
import "../node_modules/bootstrap-icons/icons/at.svg"; // email field
import "../node_modules/bootstrap-icons/icons/key.svg"; // new password field
import "../node_modules/bootstrap-icons/icons/key-fill.svg"; // pw confirm field
import "../node_modules/bootstrap-icons/icons/lock.svg"; // current pw field
import "../node_modules/bootstrap-icons/icons/shield.svg"; // role
// live tables
import "../node_modules/bootstrap-icons/icons/arrow-down-up.svg"; // sort
import "../node_modules/bootstrap-icons/icons/funnel.svg"; // filter
import "../node_modules/bootstrap-icons/icons/x-circle-fill.svg"; // clear filter
import "../node_modules/bootstrap-icons/icons/sort-down-alt.svg";
import "../node_modules/bootstrap-icons/icons/sort-up-alt.svg";
import "../node_modules/bootstrap-icons/icons/chevron-left.svg";
import "../node_modules/bootstrap-icons/icons/chevron-right.svg";
import "../node_modules/bootstrap-icons/icons/pencil.svg";
import "../node_modules/bootstrap-icons/icons/trash.svg";
// page headers
import "../node_modules/bootstrap-icons/icons/shield-lock.svg"; // reset password
import "../node_modules/bootstrap-icons/icons/arrow-repeat.svg"; // resend confirmation
import "../node_modules/@mdi/svg/svg/head-question-outline.svg"; // forgot password
import "../node_modules/bootstrap-icons/icons/people.svg"; // users management
// calendar/event icons
import "../node_modules/bootstrap-icons/icons/calendar2.svg";
import "../node_modules/bootstrap-icons/icons/calendar2-plus.svg";
import "../node_modules/bootstrap-icons/icons/calendar2-date.svg";
import "../node_modules/bootstrap-icons/icons/calendar2-event.svg";
import "../node_modules/bootstrap-icons/icons/calendar2-range.svg";
import "../node_modules/bootstrap-icons/icons/clock-history.svg"; // shift template
import "../node_modules/bootstrap-icons/icons/tag.svg";
import "../node_modules/bootstrap-icons/icons/hourglass.svg";
import "../node_modules/bootstrap-icons/icons/map.svg";
import "../node_modules/bootstrap-icons/icons/geo.svg";
import "../node_modules/bootstrap-icons/icons/justify-left.svg";
import "../node_modules/bootstrap-icons/icons/plus-circle-dotted.svg";
import "../node_modules/bootstrap-icons/icons/clipboard-plus.svg";
import "../node_modules/bootstrap-icons/icons/star.svg";
import "../node_modules/bootstrap-icons/icons/star-fill.svg";
import "../node_modules/bootstrap-icons/icons/binoculars.svg";
import "../node_modules/bootstrap-icons/icons/binoculars-fill.svg";
import "../node_modules/bootstrap-icons/icons/eraser.svg";
import "../node_modules/bootstrap-icons/icons/save.svg";
import "../node_modules/bootstrap-icons/icons/asterisk.svg";
import "../node_modules/bootstrap-icons/icons/card-list.svg";
import "../node_modules/bootstrap-icons/icons/file-earmark-spreadsheet.svg";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";

// Bootstrap v5 js imports
import "bootstrap/js/dist/alert";
import "bootstrap/js/dist/collapse";
import "bootstrap/js/dist/dropdown";
// Bootstrap helpers
import "./_hamburger-helper";
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
