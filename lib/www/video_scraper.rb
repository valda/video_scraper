require 'activesupport'
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

    modules_dir = File.join(File.dirname(__FILE__), 'video_scraper')
    Dir.foreach(modules_dir) do |file|
      next unless file.match(/^[[:alnum:]\-_]+\.rb$/)
      module_path = File.join(modules_dir, file)
      if FileTest.file?(module_path)
        logger.debug "require '#{module_path}'"
        require module_path
        logger.debug "instanciate '#{File.basename(module_path, '.rb').classify}'"
        scraper = eval(File.basename(module_path, '.rb').classify) rescue next
        if scraper.respond_to? :valid_url? and scraper.valid_url? url
          logger.info "scraper: #{scraper.to_s}"
          logger.info "url: #{url}"
          return scraper.new(opt)
        end
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
    raise
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
