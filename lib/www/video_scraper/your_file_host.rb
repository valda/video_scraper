# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class YourFileHost < Base
      url_regex %r!\Ahttp://www\.yourfilehost\.com/media\.php\?cat=video&file=.+$!

      class MaximumVideoPlaysReached < TryAgainLater; end
      class BandwidthAllowanceExceeded < TryAgainLater; end
      class NoFileCategory < FileNotFound; end

      def filename
        uri = URI.parse(@page_url)
        q = CGI.parse(uri.query)
        q['file'][0]
      end
      alias :title :filename

      def scrape
        html = http_get(@page_url)
        doc = Hpricot(html.toutf8)
        if elem = doc.at('//object[@id="objectPlayer"] //param[@name="movie"]')
          value = elem.attributes['value']
          raise StandardError, 'video information is not found' unless value
          v = CGI::parse(value)
          if request_url = v['video'][0]
            response_body = http_get(request_url)
            q = CGI::parse(response_body)
            @thumb_url = q['photo'][0] rescue ''
            @video_url = q['video_id'][0] rescue ''
          end
        elsif elem = doc.at('//object[@id="VIDEO"] //param[@name="URL"]')
          @video_url = elem.attributes['value']
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
            raise TryAgainLater, 'scrape failed'
          end
        end
      end
    end
  end
end
