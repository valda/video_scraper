# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class NicoVideo < Base
      url_regex %r!\Ahttp://www\.nicovideo\.jp/watch/([[:alnum:]]+)!

      def scrape
        begin
          login
          id = url_regex_match[1]
          get_flv(id)
          get_thumb(id)
          get_embed_tag(id)
        rescue Timeout::Error => e
          raise TryAgainLater, e.to_s
        rescue WWW::Mechanize::ResponseCodeError => e
          case e.response_code
          when '404', '403'
            raise FileNotFound, e.to_s
          when '502'
            raise TryAgainLater, e.to_s
          else
            raise TryAgainLater, e.to_s
          end
        end
      end

      private
      def login
        page = agent.post('https://secure.nicovideo.jp/secure/login?site=niconico',
                           'mail' => @opt[:nico_video_mail],
                           'password' => @opt[:nico_video_password])
        raise RuntimeError, 'login failure' unless page.header['x-niconico-authflag'] == '1'
      end

      def get_flv(id)
        request_url = "http://www.nicovideo.jp/api/getflv?v=#{id}"
        page = agent.get(request_url)
        q = CGI.parse(page.body)
        raise FileNotFound unless q['url']
        @video_url = q['url'].first
      end

      def get_thumb(id)
        page = agent.get("http://www.nicovideo.jp/api/getthumbinfo/#{id}")
        xdoc = Hpricot.XML(page.body.toutf8)
        xdoc.search('//thumbnail_url') do |elem|
          @thumb_url = elem.inner_html
        end
        xdoc.search('//thumb/title') do |elem|
          @title = elem.inner_html
        end
      end

      def get_embed_tag(id)
        page = agent.get(@page_url)
        response_body = page.body
        doc = Hpricot(response_body)
        doc.search('//form[@name="form_iframe"] //input[@name="input_iframe"]') do |elem|
          @embed_tag = elem.attributes['value']
        end
      end
    end
  end
end
