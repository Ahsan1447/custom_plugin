import { createWidget } from 'discourse/widgets/widget';
import { h } from 'virtual-dom';
import { ajax } from 'discourse/lib/ajax';
import DiscourseURL from 'discourse/lib/url';

export default createWidget('site-banner', {
  tagName: 'div.site-banner',
  buildKey: () => 'site-banner',

  defaultState() {
    return { 
      banner: null,
      loading: true
    };
  },

  init() {
    this.loadBanner();
  },

  loadBanner() {
    this.state.loading = true;
    ajax('/banner')
      .then(result => {
        this.state.banner = result.banner;
      })
      .catch(error => {
        // Ignore 404 errors (no active banner)
        if (error.jqXHR && error.jqXHR.status !== 404) {
          console.error('Error loading banner:', error);
        }
      })
      .finally(() => {
        this.state.loading = false;
        this.scheduleRerender();
      });
  },

  html(attrs, state) {
    const { banner } = state;
    
    if (!banner) {
      return;
    }

    const contents = [];
    
    contents.push(h('div.banner-title', banner.title));
    
    if (banner.button_text) {
      contents.push(
        h('div.banner-button', 
          this.attach('button', {
            className: 'btn-primary',
            label: banner.button_text,
            action: 'navigateToLink'
          })
        )
      );
    }
    
    return h('div.banner-content', contents);
  },
  
  navigateToLink() {
    const { banner } = this.state;
    if (banner && banner.button_link) {
      if (banner.button_link.startsWith('/')) {
        // Internal link
        DiscourseURL.routeTo(banner.button_link);
      } else {
        // External link
        window.open(banner.button_link, '_blank');
      }
    }
  }
});