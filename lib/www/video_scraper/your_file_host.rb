require 'video_scraper'
require 'open-uri'
require 'hpricot'
require 'cgi'
require 'uri'

module VideoScraper
  class YourFileHost
    attr_reader :request_url, :response_body, :thumb_url, :video_url, :page_url

    class MaximumVideoPlaysReached < TryAgainLater; end
    class BandwidthAllowanceExceeded < TryAgainLater; end
    class NoFileCategory < FileNotFound; end

    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      do_query
    end

    def self.valid_url?(url)
      url =~ %r{\Ahttp://www\.yourfilehost\.com/media\.php\?cat=video&file=.+$}
    end

    def filename
      uri = URI.parse(@url_share || @opt[:url])
      q = CGI.parse(uri.query)
      q['file']
    end
    alias :title :filename

    private
    def do_query
      url = @opt[:url]
      raise StandardError, 'url param is requred' unless url
      raise StandardError, "url is not YourFileHost link: #{url}" unless YourFileHost.valid_url? url
      open_opt = { 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)' }
      html = open(url, open_opt) { |res| res.read }
      doc = Hpricot(html)
      if elem = doc.at('//object[@id="objectPlayer"] //param[@name="movie"]')
        value = elem.attributes['value']
        raise StandardError, 'video information is not found' unless value
        @value = CGI::parse(value)
        if @request_url = @value['video'].shift
          @response_body = open(@request_url, open_opt) { |res| res.read }
          q = CGI::parse(@response_body)
          @thumb_url = q['photo'].shift rescue ''
          @video_url = q['video_id'].shift rescue ''
          @page_url = q['embed'].shift rescue ''
          @url_share = q['url_share'].shift rescue ''
        end
      elsif elem = doc.at('//object[@id="VIDEO"] //param[@name="URL"]')
        @video_url = elem.attributes['value']
        @page_url = url
      else
        if html =~ /MAXIMUM VIDEO PLAYS REACHED/i
          raise MaximumVideoPlaysReached, 'MAXIMUM VIDEO PLAYS REACHED'
        elsif html =~ /Bandwidth Allowance exceeded/i
          raise BandwidthAllowanceExceeded, 'Bandwidth Allowance exceeded'
        elsif html =~ /url=error\.php\?err=8/i
          raise FileNotFound, 'file not found'
        elsif html =~ /url=error\.php\?err=5/i or html =~ /no file category/i
          raise NoFileCategory, 'no file category'
        elsif html =~ /File not found/i
          raise FileNotFound, 'file not found'
        else
          raise TryAgainLater, 'scrape failed: ' + html
        end
      end
    end
  end
end

if $0 == __FILE__
  yfh = VideoScraper::YourFileHost.new('http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv')
  puts yfh.thumb_url
  puts yfh.video_url
  puts yfh.page_url
  puts yfh.title
  puts '-----------'
  yfh = VideoScraper::YourFileHost.new('http://www.yourfilehost.com/media.php?cat=video&file=kawarazaki2_ep3_002.wmv')
  puts yfh.thumb_url
  puts yfh.video_url
  puts yfh.page_url
  puts yfh.title
end
