require 'video_scraper'
require 'open-uri'
require 'hpricot'

module VideoScraper
  class Pornhub
    attr_reader :request_url, :response_body, :page_url, :video_url, :thumb_url, :embed_tag
    
    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      do_query
    end

    def self.valid_url?(url)
      url =~ %r|\Ahttp://www\.pornhub\.com/view_video\.php.*viewkey=[[:alnum:]]{20}|
    end
    
    private
    def do_query
      url = @opt[:url]
      raise StandardError, "url param is requred" unless url
      raise StandardError, "url is not pornhub link: '#{url}'" unless Pornhub.valid_url? url
      open_opt = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" }
      html = open(url, open_opt) { |res| res.read }
      raise FileNotFound unless m = html.match(/\.addVariable\("options",\s*"([^"]+)"\);/i)
      @request_url = URI.decode m[1]
      @response_body = open(@request_url, open_opt) { |res| res.read }
      @video_url = @response_body.match(%r|<flv_url>([^<]+)</flv_url>|).to_a[1]
      if m = @video_url.match(%r|videos/(\d{3}/\d{3}/\d{3})/\d+.flv|)
        @thumb_url = "http://p1.pornhub.com/thumbs/#{m[1]}/small.jpg"
      end
      @page_url = url
      if m = html.match(%r|<textarea[^>]+class="share-flag-embed">(<object type="application/x-shockwave-flash".*?</object>)</textarea>|)
        @embed_tag = m[1]
      end
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::Pornhub.new('http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0')
  #puts w.response_body
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
