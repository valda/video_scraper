require 'video_scraper'
require 'open-uri'
require 'hpricot'
require 'cgi'

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
      uri = URI.parse(url)
      q = CGI.parse(uri.query)
      @request_url = "http://www.pornhub.com/xmoov_flv/assets/styles/default/younoob2.php?viewkey=#{q['viewkey']}"
      open_opt = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" }
      @response_body = open(@request_url, open_opt) { |res| res.read }
      config_content = @response_body.match(%r|config.content\s*\{[^\{]*\}|m)[0]
      video = config_content.match(/^\s*video:\s*(.*);/)[1]
      @video_url = URI.join("http://www.pornhub.com", video).to_s
      @thumb_url = URI.join("http://www.pornhub.com/", video, 'thumbs/main.jpg').to_s
      @page_url = url
      
      response_body = open(@page_url, open_opt) { |res| res.read }
      doc = Hpricot(response_body)
      doc.search('//div.video-info //td[2] /input') do |elem|
        @embed_tag = elem.attributes['value']
      end
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::Pornhub.new('http://www.pornhub.com/view_video.php?viewkey=35f8c5b464a15c9d3567')
  #puts w.response_body
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
