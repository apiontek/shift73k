// This will tell liveview to clear a flash key
// after a bootstrap alert close event
export const AlertRemover = {
  mounted() {
    this.el.addEventListener("closed.bs.alert", () => {
      // Bootstrap finished removing the alert element
      this.pushEvent("lv:clear-flash", this.el.dataset);
    });
  },
};
