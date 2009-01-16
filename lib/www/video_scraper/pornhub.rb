# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), 'video_scraper'))

module WWW
  module VideoScraper
    class Pornhub
      VideoScraper.register_factory self
      attr_reader :request_url, :response_body, :page_url, :video_url, :thumb_url, :embed_tag
      
      def initialize(url, opt = nil)
        @page_url = url
        @opt = (opt || {})
        do_query
      end

      def self.valid_url?(url)
        url =~ %r|\Ahttp://www\.pornhub\.com/view_video\.php.*viewkey=[[:alnum:]]{20}|
      end

      private
      def http_get(url)
        open_opt = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" }
        if @opt[:cache]
          unless @opt[:cache].respond_to?(:get) and @opt[:cache].respond_to?(:set)
            raise RuntimeError, 'As for cache object what responds to :get and :set is required.'
          end
          @opt[:logger].debug 'use cache.'
          unless content = @opt[:cache].get(url)
            content = open(url, open_opt) {|fh| fh.read }
            @opt[:cache].set(url, content)
          end
        else
          content = open(url, open_opt) {|fh| fh.read }
        end
        content
      end
      
      def do_query
        raise StandardError, "url is not pornhub link: '#{@page_url}'" unless Pornhub.valid_url? @page_url
        html = http_get(@page_url)
        raise FileNotFound unless m = html.match(/\.addVariable\("options",\s*"([^"]+)"\);/i)
        @request_url = URI.decode m[1]
        @response_body = http_get(@request_url)
        @video_url = @response_body.match(%r|<flv_url>([^<]+)</flv_url>|).to_a[1]
        if m = @video_url.match(%r|videos/(\d{3}/\d{3}/\d{3})/\d+.flv|)
          @thumb_url = "http://p1.pornhub.com/thumbs/#{m[1]}/small.jpg"
        end
        if m = html.match(%r|<textarea[^>]+class="share-flag-embed">(<object type="application/x-shockwave-flash".*?</object>)</textarea>|)
          @embed_tag = m[1]
        end
      end
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::Pornhub.new('http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0')
  #puts w.response_body
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
