import AdminPluginsRoute from "discourse/routes/admin-plugins";

export default AdminPluginsRoute.extend({
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