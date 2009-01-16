# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class Pornotube < Base
      url_regex %r!\Ahttp://(?:www\.)?pornotube\.com/(?:media|channels)\.php\?.*m=(\d+)!

      def initialize(url, opt = nil)
        super
        do_query
      end

      private
      def login
        agent.post("http://pornotube.com/index.php",
                   'verifyAge' => 'true',
                   'bMonth' => '01',
                   'bDay' => '01',
                   'bYear' => '1970',
                   'submit' => 'View All Content')
      end

      def do_query
        id = url_regex_match[1]

        login
        page = agent.get(@page_url)
        raise FileNotFound unless embed = page.root.at('//object/embed')
        src = embed.attributes['src']
        hash = src.match(/\?v=(.*)$/)[1]
        page = agent.get("http://pornotube.com/player/player.php?#{hash}")
        q = CGI::parse(page.body)
        @video_url = "http://#{q['mediaDomain'][0]}.pornotube.com/#{q['userId'][0]}/#{q['mediaId'][0]}.flv"
        @thumb_url = "http://photo.pornotube.com/thumbnails/video/#{q['userId'][0]}/#{q['mediaId'][0]}.jpg";
        @image_url = "http://photo.pornotube.com/thumbnails/video/#{q['userId'][0]}/#{q['mediaId'][0]}_full.jpg";
        @embed_tag = q['embedCode'][0]
      end
    end
  end
end
