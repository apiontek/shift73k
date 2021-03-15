// Hook for custom liveview bootstrap collapse handling
import Collapse from "bootstrap/js/dist/collapse";

export const BsCollapse = {
  mounted() {
    // when the liveview mounts, create the BS collapse object
    const collapse = new Collapse(this.el, { toggle: false });

    this.handleEvent("toggle-template-details", ({ targetId }) => {
      if (this.el.id == targetId) {
        collapse.toggle();
      }
    });

    // this.el.addEventListener("show.bs.collapse", (event) => {
    //   this.pushEvent("collapse-show", { target_id: event.target.id });
    // });

    this.el.addEventListener("shown.bs.collapse", (event) => {
      this.pushEvent("collapse-shown", { target_id: event.target.id });
    });

    // this.el.addEventListener("hide.bs.collapse", (event) => {
    //   this.pushEvent("collapse-hide", { target_id: event.target.id });
    // });

    this.el.addEventListener("hidden.bs.collapse", (event) => {
      this.pushEvent("collapse-hidden", { target_id: event.target.id });
    });
  },
};

// export const BsModal = {
//   mounted() {
//     // when the liveview mounts, create the BS modal
//     const modal = new Modal(this.el);
//     // and trigger BS modal to show
//     modal.show();

//     // when the BS modal hides, send 'close' to the liveview
//     this.el.addEventListener("hidden.bs.modal", (event) => {
//       this.pushEventTo(`#${this.el.getAttribute("id")}`, "close", {});
//       modal.dispose();
//     });

//     // liveview can send this event to tell BS modal to close
//     // ex.: on successful form save, instead of immediate redirect
//     //   this event hides the BS modal, which triggers the above,
//     //   which sends 'close' to liveview and disposes the BS modal
//     this.handleEvent("modal-please-hide", (payload) => {
//       modal.hide();
//     });
//   },

//   destroyed() {
//     // when the liveview is destroyed,
//     // modal-backdrop must be forcibly removed
//     const backdrop = document.querySelector(".modal-backdrop");
//     if (backdrop) backdrop.parentElement.removeChild(backdrop);
//   },
// };
