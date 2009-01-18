# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class YouPorn < Base
      url_regex %r!\Ahttp://youporn\.com/watch/(\d+)!

      private
      def scrape
        id = url_regex_match[1]

        request_url = @page_url.sub(/(\?.*)?$/, '?user_choice=Enter')
        html = http_get(request_url, 'Cookie' => 'age_check=1')
        doc = Hpricot(html)
        doc.search('//div[@id="download"]//a').each do |elem|
          href = elem.attributes['href']
          (@video_url = href; break) if href =~ %r!^http://download\.youporn\.com/download/.*\.flv!
        end
        h1 = doc.at('//div[@id="videoArea"]/h1')
        @title = h1.inner_html.gsub(/<[^>]*>/, '').strip
        @thumb_url = h1.at('/img').attributes['src'].sub(/(\d+)_small\.jpg$/, '\1_large.jpg')
      end
    end
  end
end
