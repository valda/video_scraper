require 'video_scraper'
require 'mechanize'
require 'hpricot'
require 'uri'
require 'cgi'
require 'pp'

module VideoScraper
  class DailyMotion
    attr_reader :request_url, :response_body, :page_url, :title, :video_url, :thumb_url, :embed_tag
    
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
      url.match(%r!\Ahttp://www\.dailymotion\.com/.*?/video/([\w/-]+)!)[1] rescue nil
    end
    
    private
    def do_query
      url = @opt[:url]
      raise StandardError, "url param is requred" unless url
      raise StandardError, "url is not daily motion link: '#{url}'" unless DailyMotion.valid_url? url
      @request_url = url
      uri = URI.parse(url)
      id = DailyMotion.get_mediaid(url)
      
      page = @agent.get(url)
      @response_body = page.body
      page.root.search('//script').each do |elem|
        if elem.inner_html.match(/\.addVariable\("video",\s+"([^\"]*)"/)
          video_path = CGI.unescape($1).split(/(?:\|\||@@)/).first
          @video_url = "#{uri.scheme}://#{uri.host}#{video_path}"
        end
        if elem.inner_html.match(/\.addVariable\("preview",\s+"([^\"]*)"/)
          preview_path = CGI.unescape($1).split(/(?:\|\||@@)/).first
          @thumb_url = "#{uri.scheme}://#{uri.host}#{preview_path}"
        end
      end
      @title = page.root.at('//h1[@class="nav with_uptitle"]').inner_html rescue nil
      @page_url = page.root.at('//input[@id="video_player_permalink_text"]').attributes['value'] rescue nil
      @embed_tag = page.root.at('//input[@id="video_player_embed_code_text"]').attributes['value'] rescue nil
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::DailyMotion.new('http://www.dailymotion.com/mokelov/japan/video/x12gr3_music')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts w.page_url
  puts w.embed_tag
end
