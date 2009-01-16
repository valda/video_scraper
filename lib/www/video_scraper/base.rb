# -*- mode:ruby; coding:utf-8 -*-

module WWW
  module VideoScraper
    class Base
      attr_reader :page_url, :video_url, :thumb_url, :embed_tag
      def initialize(url, opt = nil)
        raise StandardError, "url is not #{self.class.name} link: #{url}" unless self.class.valid_url?(url)
        @page_url = url
        @opt = (opt || {})
      end

      def self.url_pattern(regex)
        @url_pattern = regex
      end
      
      def self.valid_url?(url)
        not (url =~ @url_pattern).nil?
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
      rescue OpenURI::HTTPError => e
        raise TryAgainLater, e.to_s if e.to_s.include?('503')
        raise e
      end
      
    end
  end
end
