require 'video_scraper'
require 'open-uri'
require 'hpricot'

module VideoScraper
  class AgeSage
    attr_reader :request_url, :response_body, :page_url, :video_url, :thumb_url, :title, :embed_tag
    
    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      do_query
    end

    def self.valid_url?(url)
      url =~ %r|\Ahttp://adult\.agesage\.jp/contentsPage\.html\?mcd=[[:alnum:]]{16}|
    end

    private
    def _t(text)
      REXML::Text.unnormalize(text.get_text.to_s) rescue ''
    end
    
    def do_query
      url = @opt[:url]
      raise StandardError, "url param is requred" unless url
      raise StandardError, "url is not agesage link: '#{url}'" unless AgeSage.valid_url? url
      @request_url = url.sub('.html', '.xml')
      begin
        open_opt = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" }
        @response_body = open(@request_url, open_opt) { |res| res.read }
      rescue OpenURI::HTTPError => e
        raise TryAgainLater, e.to_s if e.to_s.include?('503')
        raise
      end
      if @response_body.nil? or @response_body.empty?
        raise FileNotFound
      end
      xdoc = Hpricot.XML(@response_body.toutf8)
      if movie = xdoc.at('/movie')
        @page_url = movie.at('/pageurl').inner_html
        @video_url = movie.at('/movieurl').inner_html
        @thumb_url = movie.at('/thumbnail').inner_html
        @title = movie.at('/title').inner_html
        mcd = url.match(%r|agesage\.jp/contentsPage\.html\?mcd=([[:alnum:]]{16})|)[1]
        @embed_tag = <<-HTML
<script type="text/javascript" src="http://adult.agesage.jp/js/past_uraui.js"></script>
<script type="text/javascript">Purauifla("mcd=#{mcd}", 320, 275);</script>
        HTML
      end
    end
  end
end

if $0 == __FILE__
  agesage = VideoScraper::AgeSage.new('http://adult.agesage.jp/contentsPage.html?mcd=a6d2HPk5CftosNsg')
  #agesage = VideoScraper::AgeSage.new('http://adult.agesage.jp/contentsPage.html?mcd=QdelXBU2RemKXrZK')
  puts agesage.request_url
  #puts agesage.response_body
  puts agesage.page_url
  puts agesage.video_url
  puts agesage.thumb_url
  puts agesage.title
end
