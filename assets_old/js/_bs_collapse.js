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

    // when showing completes, send event to liveview
    this.el.addEventListener("shown.bs.collapse", (event) => {
      this.pushEvent("collapse-shown", { target_id: event.target.id });
    });

    // when hiding completes, send event to liveview
    this.el.addEventListener("hidden.bs.collapse", (event) => {
      this.pushEvent("collapse-hidden", { target_id: event.target.id });
    });
  },
};
