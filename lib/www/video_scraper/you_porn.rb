# -*- mode:ruby; coding:utf-8 -*-

require 'www/video_scraper/base'

module WWW
  module VideoScraper
    class YouPorn
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
        url.match(%r!\Ahttp://youporn\.com/watch/(\d+)!)[1] rescue nil
      end

      private
      def do_query
        url = @opt[:url]
        raise StandardError, 'url param is requred' unless url
        raise StandardError, "url is not YouPorn link: #{url}" unless YouPorn.valid_url? url
        @page_url = url
        id = YouPorn.get_mediaid(url)

        @request_url = url.sub(/(\?.*)?$/, '?user_choice=Enter')
        page = @agent.get(@request_url)
        @response_body = page.body
        page.root.search('//div[@id="download"]//a').each do |elem|
          href = elem.attributes['href']
          @video_url = href if href =~ /\.flv$/
        end
        h1 = page.root.at('//div[@id="videoArea"]/h1')
        @title = h1.inner_html.gsub(/<[^>]*>/, '').strip
        @thumb_url = h1.at('/img').attributes['src'].sub(/(\d+)_small\.jpg$/, '\1_large.jpg')
      end
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::YouPorn.new('http://youporn.com/watch/93495?user_choice=Enter')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts '--------------------'
  w = VideoScraper::YouPorn.new('http://youporn.com/watch/93495')
  puts w.title
  puts w.video_url
  puts w.thumb_url
end
