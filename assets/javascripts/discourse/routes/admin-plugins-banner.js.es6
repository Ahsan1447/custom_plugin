import Route from "@ember/routing/route";

export default Route.extend({
  controllerName: "admin-plugins-banner",
  templateName: "admin/plugins/banner",
  
  model() {
    return this.store.findAll("banner");
  },

  setupController(controller, model) {
    controller.set("model", model);
    controller.setProperties({
      newTitle: "",
      newButtonText: "",
      newButtonLink: "",
      newActive: true
    });
  }
});