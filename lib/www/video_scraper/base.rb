# -*- mode:ruby; coding:utf-8 -*-

module WWW
  module VideoScraper
    class Base
      attr_reader :page_url, :video_url, :thumb_url, :embed_tag, :title

      ## class methods
      class << self
        def url_regex(regex)
          @url_regex = regex
        end

        def valid_url?(url)
          not (url =~ @url_regex).nil?
        end
      end

      def initialize(url, opt = nil)
        @page_url = url
        @opt = (opt || {})
        @url_regex_match = self.class.instance_variable_get(:@url_regex).match(@page_url).freeze
        raise StandardError, "url is not #{self.class.name} link: #{url}" if @url_regex_match.nil?
      end

      private
      def url_regex_match; @url_regex_match; end

      def agent
        @agent ||= WWW::Mechanize.new do |a|
          a.user_agent_alias = 'Windows IE 6'
        end
      end

      def http_get(url, opt = nil)
        open_opt = {
          "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)",
        }.merge( opt || {} )
        if @opt[:cache]
          unless @opt[:cache].respond_to?(:get) and @opt[:cache].respond_to?(:set)
            raise RuntimeError, 'As for cache object what responds to :get and :set is required.'
          end
          @opt[:logger].debug 'use cache.'
          cache_key = "#{url}|#{open_opt}"
          unless content = @opt[:cache].get(cache_key)
            content = open(url, open_opt) {|fh| fh.read }
            @opt[:cache].set(cache_key, content)
          end
        else
          content = open(url, open_opt) {|fh| fh.read }
        end
        content
      rescue OpenURI::HTTPError => e
        raise TryAgainLater, e.to_s if e.to_s.include?('503')
        raise e
      end

    end
  end
end
