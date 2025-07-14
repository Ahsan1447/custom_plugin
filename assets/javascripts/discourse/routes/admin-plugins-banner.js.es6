import Route from "@ember/routing/route";

export default Route.extend({
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