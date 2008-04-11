require 'pathname'
require 'timeout'
require 'open-uri'

module VideoScraper
  class TryAgainLater < RuntimeError; end
  class FileNotFound < RuntimeError; end
  
  def self.logger
    @@logger ||= ::ActionController::Base.logger
  rescue
    require 'logger'
    @@logger ||= Logger.new(STDOUT)
  end
  
  # 与えられた URL を処理できるモジュールを、
  # video_scraper 以下から検索して実行する
  def self.scrape(opt)
    opt = opt.is_a?(String) ? { :url => opt } : opt
    url = opt[:url]
    raise StandardError, "url param is requred" unless url

    modules_dir = Pathname(File.dirname(__FILE__)) + 'video_scraper'
    modules_dir.each_entry do |file|
      next unless file.to_s.match(/^[[:alnum:]\-_]+\.rb$/)
      module_path = modules_dir + file
      if module_path.file?
        (require module_path) && (logger.info "require '#{module_path}'")
        scraper = eval(classify(module_path.to_s)) rescue next
        if scraper.respond_to?(:valid_url?) and scraper.valid_url?(url)
          logger.info "scraper: #{scraper.to_s}"
          logger.info "url: #{url}"
          return scraper.new(opt)
        end
      end
    end
    logger.info "unsupport site."
    return nil
  rescue Timeout::Error => e
    logger.warn "  Timeout : #{e.to_s}"
    raise TryAgainLater, e.to_s
  rescue OpenURI::HTTPError => e
    raise TryAgainLater, e.to_s if e.to_s.match?(/50\d/)
    raise FileNotFound, e.to_s if e.to_s.match?(/40\d/)
    raise
  rescue Exception => e
    logger.error "#{e.class}: #{e.to_s}"
    raise
  end
  
  def self.classify(filename)
    lower_case_and_underscored_word = filename.to_s.sub(/\.rb$/, '')
    lower_case_and_underscored_word.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end

  
end


if $0 == __FILE__
  [
   'http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv',
   'http://adult.agesage.jp/contentsPage.html?mcd=oadyChZgcoN9rqbJ',
   'http://www.morotube.com/watch.php?clip=46430e1d',
   'http://www.pornhub.com/view_video.php?viewkey=35f8c5b464a15c9d3567',
   'http://www.redtube.com/8415',
  ].each do |url|
    vs = VideoScraper.scrape(url)
    puts vs.class
    puts vs.video_url
    puts '-------------'
  end
end
