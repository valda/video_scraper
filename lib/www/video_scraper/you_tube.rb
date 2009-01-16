# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), 'video_scraper'))

module WWW
  module VideoScraper
    class YouTube
      @@options ||= {}

      def self.options
        @@options
      end

      def self.options=(opts)
        @@options = opts
      end

      def self.configure(&proc)
        raise ArgumentError, 'Block is required.' unless block_given?
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
        login_form = page.forms.with.name('loginForm').first
        login_form.username = YouTube.options[:mail]
        login_form.password = YouTube.options[:password]
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
        raise StandardError, 'url param is requred' unless url
        raise StandardError, "url is not YouTube link: #{url}" unless YouTube.valid_url? url
        @page_url = url
        uri = URI.parse(@page_url)
        @page_uri = uri

        page = pass_verify_age
        @response_body = page.body
        @title = page.root.at('//head/title').inner_html rescue ''
        @embed_tag = page.root.at('//input[@id="embed_code"]').attributes['value'] rescue nil
        uri.path = '/get_video'
        page.root.search('//script').each do |script|
          if script.inner_html.match(/var\s+swfArgs\s*=\s*([^;]+);/)
            swf_args = JSON::parse($1)
            uri.query = "video_id=#{swf_args['video_id']}&t=#{swf_args['t']}"
            @video_url = uri.to_s
            @thumb_url = "http://i.ytimg.com/vi/#{swf_args['video_id']}/default.jpg"
          end
        end
        raise FileNotFound, 'file not found' if @embed_tag.nil? and @video_url.nil? and @thumb_url.nil?
      end
    end
  end
end

if $0 == __FILE__
  require 'yaml'
  y = YAML.load_file(File.join(ENV['HOME'], '.videoscraperrc'))
  VideoScraper::YouTube.configure do |conf|
    conf[:mail] = y['youtube']['mail']
    conf[:password] = y['youtube']['password']
  end

  w = VideoScraper::YouTube.new('http://www.youtube.com/watch?v=OFPnvARUOHI&feature=dir')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
  puts '---------------'
  w = VideoScraper::YouTube.new('http://www.youtube.com/watch?v=ysdSl5kmzFY&feature=bz303')
  puts w.title
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
