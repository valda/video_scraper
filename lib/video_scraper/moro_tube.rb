require 'video_scraper'
require 'open-uri'
require 'hpricot'
require 'cgi'

module VideoScraper
  class MoroTube
    attr_reader :request_url, :response_body, :title, :video_url, :thumb_url, :author, :duration, :page_url, :embed_tag
    
    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      do_query
    end
    
    def self.valid_url?(url)
      url =~ %r|\Ahttp://www\.morotube\.com/watch\.php\?clip=[[:alnum:]]{8}|
    end
    
    private
    def do_query
      url = @opt[:url]
      raise StandardError, "url param is requred" unless url
      raise StandardError, "url is not morotube link: '#{url}'" unless MoroTube.valid_url? url
      uri = URI.parse(url)
      video_id = CGI.parse(uri.query)['clip']
      @request_url = URI.join("#{uri.scheme}://#{uri.host}", "gen_xml.php?type=o&id=#{video_id}")
      open_opt = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" }
      @response_body = open(@request_url, open_opt) { |res| res.read }
      xdoc = Hpricot.XML(@response_body.toutf8)
      @title = xdoc.search('/root/video/title').inner_html
      @video_url = xdoc.search('/root/video/file').inner_html
      @thumb_url = xdoc.search('/root/video/image').inner_html
      @author = xdoc.search('/root/video/author').inner_html
      @duration = xdoc.search('/root/video/duration').inner_html
      @page_url = xdoc.search('/root/video/link').inner_html
      
      response_body = open(url, open_opt) { |res| res.read }
      doc = Hpricot(response_body)
      doc.search('//input#inpVdoEmbed') do |elem|
        @embed_tag = elem.attributes['value']
      end
    rescue OpenURI::HTTPError => e
      raise TryAgainLater, e.to_s if e.to_s.include?('503')
      raise
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::MoroTube.new('http://www.morotube.com/watch.php?clip=46430e1d')
  puts w.request_url
  puts w.response_body
  puts w.video_url
  puts w.thumb_url
  puts w.page_url
  puts w.title
  puts w.author
  puts w.duration
  puts w.embed_tag
end
