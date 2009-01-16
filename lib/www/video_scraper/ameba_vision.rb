# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), 'video_scraper'))

module WWW
  module VideoScraper
    class AmebaVision
      attr_reader :request_url, :response_body, :page_url, :title, :video_url, :thumb_url

      def initialize(opt)
        @opt = opt.is_a?(String) ? { :url => opt } : opt
        @agent = WWW::Mechanize.new
        @agent.user_agent_alias = 'Windows IE 6'
        do_query
      end

      def self.valid_url?(url)
        get_mediaid(url)
      end

      def self.get_mediaid(url)
        url.match(%r!\Ahttp://vision\.ameba\.jp/watch\.do.*?\?movie=(\d+)!)[1] rescue nil
      end

      private
      def do_query
        url = @opt[:url]
        raise StandardError, 'url param is requred' unless url
        raise StandardError, "url is not AmebaVision link: #{url}" unless AmebaVision.valid_url? url
        id = AmebaVision.get_mediaid(url)

        @request_url = "http://vision.ameba.jp/api/get/detailMovie.do?movie=#{id}"
        page = @agent.get(@request_url)
        @response_body = page.body
        xdoc = Hpricot.XML(@response_body.toutf8)
        video =
          @title = xdoc.at('//item/title').inner_html
        @page_url = xdoc.at('//item/link').inner_html
        @thumb_url = xdoc.at('//item/imageUrlLarge').inner_html
        @video_url = @thumb_url.sub('//vi', '//vm').sub('/jpg/', '/flv/').sub('_4.jpg', '.flv')
      end
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::AmebaVision.new('http://vision.ameba.jp/watch.do?movie=772341')
  puts w.title
  puts w.page_url
  puts w.video_url
  puts w.thumb_url
end
