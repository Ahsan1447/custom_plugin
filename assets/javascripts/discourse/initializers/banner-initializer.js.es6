import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: "banner-initializer",
  initialize(container) {
    withPluginApi('0.11.2', api => {
      // Add the banner component above the header
      api.decorateWidget('header:before', helper => {
        return helper.attach('site-banner');
      });
    });
  }
}