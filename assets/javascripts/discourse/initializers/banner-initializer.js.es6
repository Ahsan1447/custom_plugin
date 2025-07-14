import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: "banner-initializer",
  initialize(container) {
    withPluginApi('0.8.0', api => {
      // Mount banner component above site header
      api.renderInOutlet('above-site-header', 'site-banner');
    });
  }
}