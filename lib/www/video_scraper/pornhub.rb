# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class Pornhub < Base
      url_regex %r|\Ahttp://www\.pornhub\.com/view_video\.php.*viewkey=[[:alnum:]]{20}|

      private
      def scrape
        html = http_get(@page_url)
        raise FileNotFound unless m = html.match(/\.addVariable\("options",\s*"([^"]+)"\);/i)
        @request_url = URI.decode m[1]
        @response_body = http_get(@request_url)
        @video_url = @response_body.match(%r|<flv_url>([^<]+)</flv_url>|).to_a[1]
        if m = @video_url.match(%r|videos/(\d{3}/\d{3}/\d{3})/\d+.flv|)
          @thumb_url = "http://p1.pornhub.com/thumbs/#{m[1]}/small.jpg"
        end
        @embed_tag = html.match(%r|<textarea[^>]+class="share-flag-embed">(<object type="application/x-shockwave-flash".*?</object>)</textarea>|).to_a[1]
      end
    end
  end
end
