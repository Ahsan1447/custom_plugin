import RestModel from "discourse/models/rest";

export default RestModel.extend({
  updateProperties() {
    return this.getProperties(
      "title",
      "button_text",
      "button_link",
      "active"
    );
  }
});

// Register the model with the store
RestModel.registerModelClass("banner", {
  createFromJson(json) {
    return RestModel.create(json);
  },
  updateFromJson(json) {
    return RestModel.create(json);
  },
  update(model, props) {
    model.setProperties(props);
    return model;
  }
});