import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  classNames: ["site-banner"],
  banner: null,
  loading: true,

  init() {
    this._super(...arguments);
    this.loadBanner();
  },

  loadBanner() {
    this.set("loading", true);
    ajax("/banner")
      .then(result => {
        this.set("banner", result.banner);
      })
      .catch(error => {
        if (error.jqXHR && error.jqXHR.status !== 404) {
          popupAjaxError(error);
        }
      })
      .finally(() => {
        this.set("loading", false);
      });
  },

  actions: {
    navigateToLink() {
      const link = this.banner.button_link;
      if (link) {
        if (link.startsWith("/")) {
          // Internal link
          this.router.transitionTo(link.substring(1));
        } else {
          // External link
          window.open(link, "_blank");
        }
      }
    }
  }
});