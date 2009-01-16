# -*- mode:ruby; coding:utf-8 -*-

require 'www/video_scraper/base'

module WWW
  module VideoScraper
    class AgeSage < Base
      url_pattern %r!\Ahttp://adult\.agesage\.jp/contentsPage\.html\?mcd=[[:alnum:]]{16}!
      
      def initialize(url, opt = nil)
        super
        do_query
      end

      private
      def do_query
        @request_url = @page_url.sub('.html', '.xml')
        @response_body = http_get(@request_url)
        raise FileNotFound if @response_body.nil? or @response_body.empty?
        xdoc = Hpricot.XML(@response_body.toutf8)
        if movie = xdoc.at('/movie')
          @video_url = movie.at('/movieurl').inner_html
          @thumb_url = movie.at('/thumbnail').inner_html
          @title = movie.at('/title').inner_html
          mcd = @page_url.match(%r|agesage\.jp/contentsPage\.html\?mcd=([[:alnum:]]{16})|)[1]
          @embed_tag = <<-HTML
<script type="text/javascript" src="http://adult.agesage.jp/js/past_uraui.js"></script>
<script type="text/javascript">Purauifla("mcd=#{mcd}", 320, 275);</script>
        HTML
        end
      end
    end
  end
end
