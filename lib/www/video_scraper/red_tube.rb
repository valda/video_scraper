# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class RedTube < Base
      url_regex %r|\Ahttp://www\.redtube\.com/(\d+)|

      def scrape
        s = content_id || '0'
        s = '1' if s.empty?
        pathnr = s.to_i / 1000
        s = "%07d" % s.to_i
        logger.debug s
        pathnr = "%07d" % pathnr
        logger.debug pathnr
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
        @pathnr = pathnr
        @s = s
        @video_url = "http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/#{content_video}"
      end

      def thumb_url
        return @thumb_url if @thumb_url
        1.upto(10) do |i|
          url = "http://thumbs.redtube.com/_thumbs/#{@pathnr}/#{@s}/#{@s}_#{'%03d' % i}.jpg"
          logger.debug url
          begin
            uri = URI.parse(url)
            Net::HTTP.start(uri.host, uri.port) do |http|
              response = http.head(uri.request_uri,
                                   {"User-Agent" => "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)"})
              logger.debug response.code
              if 200 == response.code.to_i
                @thumb_url = url
                return @thumb_url
              end
            end
          rescue TimeoutError, Timeout::Error, Errno::ETIMEDOUT
          end
        end
        nil
      end

      def title
        return @title if @title
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        @title = doc.at("//table/tr[2]/td/table/tr[3]/td/table/tr/td").inner_html.gsub(/<[^>]*>/, '').strip
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
    end
  end
end
