import Component from "@ember/component";

export default Component.extend({
  init() {
    this._super(...arguments);
    const category = this.category;
    
    if (!category.custom_fields) {
      category.custom_fields = {};
    }
    
    this.set('categoryModel', category);
  },

  actions: {
    onChangePostView(value) {
      this.set('categoryModel.custom_fields.post_view', value);
    },
    
    onChangeTabsView(value) {
      this.set('categoryModel.custom_fields.tabs_view', value);
    },
    
    onChangeUserCanCreatePost(value) {
      this.set('categoryModel.custom_fields.user_can_create_post', value);
    },

    onChangeMainPostView(value) {
      this.set('categoryModel.custom_fields.show_main_post', value);
    }
  }
}); 