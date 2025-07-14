import Controller from "@ember/controller";
import { computed } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  newTitle: "",
  newButtonText: "",
  newButtonLink: "",
  newActive: true,

  createDisabled: computed("newTitle", function() {
    return !this.newTitle || this.newTitle.trim().length === 0;
  }),

  actions: {
    createBanner() {
      const banner = this.store.createRecord("banner", {
        title: this.newTitle,
        button_text: this.newButtonText,
        button_link: this.newButtonLink,
        active: this.newActive
      });

      banner
        .save()
        .then(() => {
          this.setProperties({
            newTitle: "",
            newButtonText: "",
            newButtonLink: "",
            newActive: true
          });
          this.model.pushObject(banner);
        })
        .catch(popupAjaxError);
    },

    deleteBanner(banner) {
      banner
        .destroyRecord()
        .then(() => {
          this.model.removeObject(banner);
        })
        .catch(popupAjaxError);
    },

    toggleActive(banner) {
      const newActive = !banner.active;
      banner.set("active", newActive);
      
      ajax(`/admin/banners/${banner.id}`, {
        type: "PUT",
        data: { banner: { active: newActive } }
      })
        .then(() => {
          this.model.forEach(b => {
            if (b !== banner && newActive) {
              b.set("active", false);
            }
          });
        })
        .catch(popupAjaxError);
    }
  }
});