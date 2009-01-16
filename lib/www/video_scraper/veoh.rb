require 'video_scraper'
require 'mechanize'
require 'hpricot'
require 'kconv'

module VideoScraper
  class Veoh
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
      url.match(%r!\Ahttp://www\.veoh\.com/videos/(\w+)!)[1] rescue nil
    end

    private
    def do_query
      url = @opt[:url]
      raise StandardError, 'url param is requred' unless url
      raise StandardError, "url is not Veoh link: #{url}" unless Veoh.valid_url? url
      @page_url = url
      id = Veoh.get_mediaid(url)

      @request_url = "http://www.veoh.com/rest/video/#{id}/details"
      page = @agent.get(@request_url)
      @response_body = page.body
      xdoc = Hpricot.XML(@response_body.toutf8)
      video = xdoc.at('//video')
      @video_url = video.attributes['fullPreviewHashPath']
      @title = video.attributes['title']
      @thumb_url = video.attributes['fullMedResImagePath']
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::Veoh.new('http://www.veoh.com/videos/v6245232rh8aGEM9')
  puts w.title
  puts w.video_url
  puts w.thumb_url
end
