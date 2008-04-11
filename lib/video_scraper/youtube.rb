require 'video_scraper'
require 'mechanize'
require 'hpricot'
require 'json'
require 'uri'
require 'pp'
require 'logger'

  module VideoScraper
    class Youtube
      @@options ||= {}
      
      def self.options
        @@options
      end
      
      def self.options=(opts)
        @@options = opts
      end

      def self.configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @@options
      end
      
      attr_reader :request_url, :response_body, :page_url, :title, :video_url, :thumb_url, :embed_tag
      
      def initialize(opt)
        @opt = opt.is_a?(String) ? { :url => opt } : opt
        @agent = WWW::Mechanize.new
        @agent.user_agent_alias = 'Windows IE 6'
        @agent.keep_alive = false
        do_query
      end

      def self.valid_url?(url)
        get_mediaid(url)
      end

      def self.get_mediaid(url)
        begin
          uri = URI.parse(url)
        rescue
          return nil
        end
        return nil unless uri.host.match(%r!(?:www|jp)\.youtube\.com!)
        url.match(%r![?&]v=([[:alnum:]]+)!)[1] rescue nil
      end
      
      private
      def login
        page = @agent.get("#{@page_uri.scheme}://#{@page_uri.host}/login")
        login_form = page.forms.with.name("loginForm").first
        login_form.username = Youtube.options[:mail]
        login_form.password = Youtube.options[:password]
        @agent.submit(login_form)
      end

      def pass_verify_age
        page = @agent.get(@page_url)
        if page.uri.path =~ /verify_age/
          # ログインする
          login
          # 確認フォームを送信
          page = @agent.post(page.uri,
                             'next_url' => "#{@page_uri.path}?#{@page_uri.query}",
                             'action_confirm' => 'Confirm Birth Date')
        end
        page
      end
      
      def do_query
        url = @opt[:url]
        raise StandardError, "url param is requred" unless url
        raise StandardError, "url is not youtube link: '#{url}'" unless Youtube.valid_url? url
        @page_url = url
        @page_uri = URI.parse(@page_url)
        
        page = pass_verify_age
        @response_body = page.body
        @title = page.root.at('//head/title').inner_html rescue ''
        @embed_tag = page.root.at('//input[@id="embed_code"]').attributes['value'] rescue nil
        page.root.search('//script').each do |script|
          if m = script.inner_html.match(/var\s+swfArgs\s+=\s+([^;]*);/)
            swf_args = JSON::parse(m[1])
            uri = URI.parse(url)
            @video_url = "#{uri.scheme}://#{uri.host}/get_video?video_id=#{swf_args['video_id']}&t=#{swf_args['t']}"
            @thumb_url = "http://i.ytimg.com/vi/#{swf_args['video_id']}/default.jpg"
          end
        end
        raise FileNotFound, "file not found" if @embed_tag.nil? and @video_url.nil? and @thumb_url.nil?
      end
    end
  end

if $0 == __FILE__
  require 'yaml'
  y = YAML.load_file(File.join(ENV['HOME'], '.videoscraperrc'))
  VideoScraper::Youtube.configure do |conf|
    conf[:mail] = y["youtube"]["mail"]
    conf[:password] = y["youtube"]["password"]
  end

  w = VideoScraper::Youtube.new('http://www.youtube.com/watch?v=OFPnvARUOHI&feature=dir')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
  puts '---------------'
  w = VideoScraper::Youtube.new('http://www.youtube.com/watch?v=ysdSl5kmzFY&feature=bz303')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
