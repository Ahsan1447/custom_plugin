import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "admin-banner",
  initialize() {
    withPluginApi("0.8.0", api => {
      api.addNavigationBarItem({
        name: "banner",
        displayName: I18n.t("banner.page_title"),
        href: "/admin/plugins/banner"
      });
    });
  }
}; 