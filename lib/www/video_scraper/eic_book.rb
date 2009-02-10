# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class EicBook < Base
      attr_reader :capture_urls
      url_regex %r!\Ahttp://www\.eic-book\.com/(detail_\d+\.html).*!

      def scrape
        uri = URI.parse(@page_url)
        @page_url = "#{uri.scheme}://#{uri.host}#{uri.path}?flg=sm"
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        raise FileNotFound unless flashvars = doc.at('//object //param[@name="FlashVars"]')
        flashvars = CGI.parse(flashvars.attributes['value'])
        @video_url = flashvars['flv'][0]
        @title = CGI.unescapeHTML(doc.at('//h2[@class="detailTtl"]').inner_html).gsub('&nbsp;', ' ') rescue nil
        html = http_get("#{uri.scheme}://#{uri.host}#{uri.path}?flg=h4")
        doc = Hpricot(html.toutf8)
        if img = doc.at('//div[@class="detailMN"]/img[@class="waku01"]')
          @thumb_url = URI.join("#{uri.scheme}://#{uri.host}", img.attributes['src']).to_s
        end
        html = http_get("#{uri.scheme}://#{uri.host}#{uri.path}?flg=cp")
        doc = Hpricot(html.toutf8)
        @capture_urls = []
        doc.search('//div[@class="detailMN"]/img[@class="waku01"]') do |img|
          @capture_urls << URI.join("#{uri.scheme}://#{uri.host}", img.attributes['src']).to_s
        end
      end
    end
  end
end
