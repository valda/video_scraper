# -*- mode:ruby; coding:utf-8 -*-

require 'www/video_scraper/base'

module WWW
  module VideoScraper
    class RedTube < Base
      url_regex %r|\Ahttp://www\.redtube\.com/(\d{4})|

      def initialize(url, opt = nil)
        super
        do_query
      end

      def embed_tag
        return @embed_tag if @embed_tag
        url = "http://www.redtube.com/embed/#{content_id}"
        response_body = http_get(url)
        doc = Hpricot(response_body)
        doc.search('//textarea#cpf') do |elem|
          @embed_tag = elem.inner_html
        end
        @embed_tag
      end

      private
      def content_id; url_regex_match[1]; end

      def do_query
        s = content_id || '0'
        s = '1' if s.empty?
        pathnr = s.to_i / 1000
        s = "%07d" % s.to_i
        pathnr = "%07d" % pathnr
        xc = %w!R 1 5 3 4 2 O 7 K 9 H B C D X F G A I J 8 L M Z 6 P Q 0 S T U V W E Y N!
        qsum = 0
        s.length.times do |i|
          qsum += s[i,1].to_i * (i + 1)
        end
        s1 = qsum.to_s
        qsum = 0
        s1.length.times do |i|
          qsum += s1[i,1].to_i
        end
        qstr = "%02d" % qsum
        code = ''
        code += xc[s[3] - 48 + qsum + 3]
        code += qstr[1,1]
        code += xc[s[0] - 48 + qsum + 2]
        code += xc[s[2] - 48 + qsum + 1]
        code += xc[s[5] - 48 + qsum + 6]
        code += xc[s[1] - 48 + qsum + 5]
        code += qstr[0,1]
        code += xc[s[4] - 48 + qsum + 7]
        code += xc[s[6] - 48 + qsum + 4]
        content_video = pathnr + '/' + code + '.flv'
        @video_url = "http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/#{content_video}"
        # @thumb_url = "http://thumbs.redtube.com/_thumbs/#{pathnr}/#{s}/#{s}_#{'%03d' % i}.jpg"
      end
    end
  end
end
