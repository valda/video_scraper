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
    class TryAgainLater < RuntimeError; end
    class FileNotFound < RuntimeError; end

    @@options = {
      :logger => nil,
      :cache => nil,
      :debug => false,
    }
    @@scrapers = []
    
    class << self
      def self.options
        @@options
      end
      
      def self.options=(opts)
        @@options = opts
      end

      def configure(&proc)
        raise ArgumentError, "Block is required." unless block_given?
        yield @@options
      end

    # ファクトリに登録
      def register_factory(scraper)
        @@scrapers << scraper
      end
      
      # 与えられた URL を処理できるモジュールを @@scrapers から検索して実行する
      def scrape(url, opt = nil)
        opt = @@options.merge(opt || {})
        opt[:logger] ||= logger
        raise StandardError, "url param is requred" unless url

        @@scrapers.each do |scraper|
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


if $0 == __FILE__
  [
   'http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0',
   #   'http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv',
   #   'http://adult.agesage.jp/contentsPage.html?mcd=oadyChZgcoN9rqbJ',
   #   'http://www.morotube.com/watch.php?clip=46430e1d',
   #   'http://www.pornhub.com/view_video.php?viewkey=35f8c5b464a15c9d3567',
   #   'http://www.redtube.com/8415',
  ].each do |url|
    vs = VideoScraper.scrape(url)
    puts vs.class
    puts vs.video_url
    puts vs.thumb_url
    puts vs.embed_tag
    puts '-------------'
  end
end
