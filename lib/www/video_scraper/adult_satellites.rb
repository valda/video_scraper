# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class AdultSatellites < Base
      url_regex %r!http://(?:www\.)?asa\.tv/movie_detail\.php.*!

      def scrape
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        raise FileNotFound unless flashvars = doc.at('//object //param[@name="FlashVars"]')
        flashvars = CGI.parse(flashvars.attributes['value'])
        @video_url = flashvars['videoName'][0]
        uri = URI.parse(@page_url)
        if m = @video_url.match(%r!/([[:alnum:]]+/[[:alnum:]]+)\.flv!)
          @thumb_url = "#{uri.scheme}://#{uri.host}/captured/#{m[1]}_1.jpg"
        end
        @title = doc.at('//strong[@class="ptitle"]').inner_html rescue nil
        if embed = doc.at('//input[@name="embed"]')
          @embed_tag = CGI.unescapeHTML(embed.attributes['value'])
        end
      end
    end
  end
end
