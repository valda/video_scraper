# -*- mode:ruby; coding:utf-8 -*-

require 'www/video_scraper/base'

module WWW
  module VideoScraper
    class MoroTube < Base
      url_regex %r!\Ahttp://www\.morotube\.com/watch\.php\?clip=([[:alnum:]]{8})!
      attr_reader :author, :duration

      def initialize(url, opt = nil)
        super
        do_query
      end

      private
      def do_query
        uri = URI.parse(@page_url)
        uri.path = '/gen_xml.php'
        uri.query = "type=o&id=#{url_regex_match[1]}"
        xml = http_get(uri.to_s)
        xdoc = Hpricot.XML(xml.toutf8)
        @title = xdoc.search('/root/video/title').inner_html
        @video_url = xdoc.search('/root/video/file').inner_html
        @thumb_url = xdoc.search('/root/video/image').inner_html
        @author = xdoc.search('/root/video/author').inner_html
        @duration = xdoc.search('/root/video/duration').inner_html

        html = http_get(@page_url)
        doc = Hpricot(html)
        doc.search('//input#inpVdoEmbed') do |elem|
          @embed_tag = elem.attributes['value']
        end
      end
    end
  end
end
