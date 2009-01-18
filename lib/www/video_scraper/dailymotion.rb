# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class Dailymotion < Base
      url_regex %r!\Ahttp://www\.dailymotion\.com/.*?/video/([\w/-]+)!

      private
      def scrape
        uri = URI.parse(@page_url)
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        doc.search('//script').each do |elem|
          if m = elem.inner_html.match(/\.addVariable\("video",\s*"([^"]+)"/i)
            path = CGI.unescape(m[1]).split(/\|\||@@/).first
            @video_url = URI.join("#{uri.scheme}://#{uri.host}", path).to_s
          end
          if m = elem.inner_html.match(/\.addVariable\("preview",\s+"([^"]+)"/)
            path = CGI.unescape(m[1]).split(/\|\||@@/).first
            @thumb_url = URI.join("#{uri.scheme}://#{uri.host}", path).to_s
          end
        end
        @title = doc.at('//h1[@class="nav"]').inner_html rescue nil
        @embed_tag = CGI.unescapeHTML(doc.at('//textarea[@id="video_player_embed_code_text"]').inner_html) rescue nil
      end
    end
  end
end

