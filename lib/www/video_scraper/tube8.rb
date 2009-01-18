# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class Tube8 < Base
      url_regex %r!\Ahttp://www\.tube8\.com/.*/(\d+)(?:/|$)!

      def initialize(url, opt = nil)
        super
        do_query
      end

      private
      def do_query
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        raise FileNotFound unless flashvars = doc.at('//object //param[@name="FlashVars"]')
        flashvars = CGI.parse(flashvars.attributes['value'])
        @video_url = flashvars['videoUrl'][0]
        uri = URI.parse(@page_url)
        @thumb_url = URI.join("#{uri.scheme}://#{uri.host}", flashvars['imageUrl'][0]).to_s
        @title = doc.at('//h1[@class="text"]').inner_html rescue nil
      end
    end
  end
end
