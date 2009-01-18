# -*- mode:ruby; coding:utf-8 -*-

require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'kconv'
require 'json'
require 'uri'
begin
  require 'cgialt'
rescue LoadError
  require 'cgi'
end

module WWW
  module VideoScraper
    VERSION = '1.0.2'

    MODULES_NAME = %w(age_sage ameba_vision dailymotion moro_tube
                      nico_video pornhub pornotube red_tube tube8 veoh
                      you_porn you_tube your_file_host)

    @@modules = MODULES_NAME.map do |name|
      require File.expand_path(File.join(File.dirname(__FILE__), 'video_scraper', name))
      const_get( name.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase } )
    end

    @@options = {
      :logger => nil,
      :cache => nil,
      :debug => false,
    }

    class << self
      def options
        @@options
      end

      def options=(opts)
        @@options = opts
      end

      def configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @@options
      end

      # 与えられた URL を処理できるモジュールを @@modules から検索して実行する
      def scrape(url, opt = nil)
        opt = @@options.merge(opt || {})
        opt[:logger] ||= logger
        raise StandardError, "url param is requred" unless url

        @@modules.each do |scraper|
          if scraper.valid_url?(url)
            logger.info "scraper: #{scraper.to_s}"
            logger.info "url: #{url}"
            return scraper.new(url, opt)
          end
        end
        logger.info "unsupport site."
        return nil
      rescue TimeoutError, Timeout::Error, Errno::ETIMEDOUT => e
        logger.warn "  Timeout : #{e.to_s}"
        raise TryAgainLater, e.to_s
      rescue OpenURI::HTTPError => e
        raise TryAgainLater, e.to_s if e.to_s.match(/50\d/)
        raise FileNotFound, e.to_s if e.to_s.match(/40\d/)
        raise
      rescue Exception => e
        logger.error "#{e.class}: #{e.to_s}"
        raise e
      end

      private
      def logger
        return @@options[:logger] if @@options[:logger]
        require 'logger'
        @@options[:logger] = Logger.new(STDOUT)
      end
    end
  end
end
