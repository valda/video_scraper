# -*- mode:ruby; coding:utf-8 -*-

require 'www/video_scraper/base'

module WWW
  module VideoScraper
    class NicoVideo
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

      attr_reader :request_url, :response_body, :page_url, :video_url, :thumb_url, :embed_tag

      def initialize(opt)
        @opt = opt.is_a?(String) ? { :url => opt } : opt
        @agent = WWW::Mechanize.new
        @agent.user_agent_alias = 'Windows IE 6'
        do_query
      end

      def self.valid_url?(url)
        url =~ %r|\Ahttp://www\.nicovideo\.jp/watch/sm\d{7}|
      end

      private
      def login
        page = @agent.post('https://secure.nicovideo.jp/secure/login?site=niconico',
                           'mail' => NicoVideo.options[:mail],
                           'password' => NicoVideo.options[:password])
        raise RuntimeError, 'login failure' unless page.header['x-niconico-authflag'] == '1'
      end

      def get_flv(id)
        @request_url = "http://www.nicovideo.jp/api/getflv?v=#{id}"
        page = @agent.get(@request_url)
        @response_body = page.body
        q = CGI.parse(@response_body)
        raise FileNotFound unless q['url']
        @video_url = q['url'].first
      end

      def get_thumb(id)
        page = @agent.get("http://www.nicovideo.jp/api/getthumbinfo/#{id}")
        response_body = page.body
        xdoc = Hpricot.XML(response_body.toutf8)
        xdoc.search('//thumbnail_url') do |elem|
          @thumb_url = elem.inner_html
        end
      end

      def get_embed_tag(id)
        page = @agent.get("http://www.nicovideo.jp/watch/#{id}")
        response_body = page.body
        doc = Hpricot(response_body)
        doc.search('//form[@name="paste_iframe"] //input') do |elem|
          @embed_tag = elem.attributes['value']
        end
      end

      def do_query
        url = @opt[:url]
        raise StandardError, 'url param is requred' unless url
        raise StandardError, "url is not Nico Video link: #{url}" unless NicoVideo.valid_url? url
        @page_url = url
        id = url.match(%r|www\.nicovideo\.jp/watch/([[:alnum:]]+)|)[1]

        begin
          login
          get_flv(id)
          get_thumb(id)
          get_embed_tag(id)
        rescue Timeout::Error => e
          raise TryAgainLater, e.to_s
        rescue WWW::Mechanize::ResponseCodeError => e
          case e.response_code
          when '404', '403'
            raise FileNotFound, e.to_s
          when '502'
            raise TryAgainLater, e.to_s
          else
            raise TryAgainLater, e.to_s
          end
        end
      end
    end
  end
end

if $0 == __FILE__
  require 'yaml'
  y = YAML.load_file(File.join(ENV['HOME'], '.videoscraperrc'))
  VideoScraper::NicoVideo.configure do |conf|
    conf[:mail] = y['nico_video']['mail']
    conf[:password] = y['nico_video']['password']
  end
  w = VideoScraper::NicoVideo.new('http://www.nicovideo.jp/watch/sm2909967')
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
