require 'video_scraper'
require 'mechanize'
require 'hpricot'
require 'kconv'
require 'cgi'

module VideoScraper
  class Pornotube
    attr_reader :request_url, :response_body, :page_url, :video_url, :thumb_url, :embed_tag

    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      @agent = WWW::Mechanize.new
      @agent.user_agent_alias = 'Windows IE 6'
      do_query
    end

    def self.valid_url?(url)
      get_mediaid(url)
    end

    def self.get_mediaid(url)
      if url.match(%r!\Ahttp://(?:www\.)?pornotube\.com/(?:media|channels)\.php\?.*m=(\d+)!)
        return $1
      end
      nil
    end

    private
    def login
      @agent.post("http://pornotube.com/index.php",
                  'verifyAge' => 'true',
                  'bMonth' => '01', 'bDay' => '01', 'bYear' => '1970')
    end

    def do_query
      url = @opt[:url]
      raise StandardError, "url param is requred" unless url
      raise StandardError, "url is not Pornotube link: #{url}" unless Pornotube.valid_url? url
      @page_url = url
      id = Pornotube.get_mediaid(url)

      login
      page = @agent.get(@page_url)
      embed = page.root.at('//object/embed')
      raise FileNotFound unless embed
      src = embed.attributes['src']
      hash = src.match(/\?v=(.*)$/)[1]
      page = @agent.get("http://pornotube.com/player/player.php?#{hash}")
      @response_body = page.body
      q = CGI::parse(@response_body)
      @video_url = "http://#{q['mediaDomain'][0]}.pornotube.com/#{q['userId'][0]}/#{q['mediaId'][0]}.flv"
      @thumb_url = "http://photo.pornotube.com/thumbnails/video/#{q['userId'][0]}/#{q['mediaId'][0]}.jpg";
      @image_url = "http://photo.pornotube.com/thumbnails/video/#{q['userId'][0]}/#{q['mediaId'][0]}_full.jpg";
      @embed_tag = q['embedCode'][0]
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::Pornotube.new('http://pornotube.com/media.php?m=1515295')
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
  puts '---------------------'
  w = VideoScraper::Pornotube.new('http://www.pornotube.com/channels.php?channelId=83&m=1563023')
  puts w.video_url
  puts w.thumb_url
  puts w.embed_tag
end
