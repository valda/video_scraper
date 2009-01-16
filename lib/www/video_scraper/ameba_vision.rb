# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class AmebaVision < Base
      url_regex %r!\Ahttp://vision\.ameba\.jp/watch\.do.*?\?movie=(\d+)!

      def initialize(url, opt = nil)
        super
        do_query
      end

      private
      def do_query
        id = url_regex_match[1]
        request_url = "http://vision.ameba.jp/api/get/detailMovie.do?movie=#{id}"
        xml = http_get(request_url)
        xdoc = Hpricot.XML(xml.toutf8)
        @title = xdoc.at('//item/title').inner_html
        @page_url = xdoc.at('//item/link').inner_html
        @thumb_url = xdoc.at('//item/imageUrlLarge').inner_html
        @video_url = @thumb_url.sub('//vi', '//vm').sub('/jpg/', '/flv/').sub('_4.jpg', '.flv')
      end
    end
  end
end
