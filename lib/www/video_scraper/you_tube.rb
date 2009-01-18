# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/base')

module WWW
  module VideoScraper
    class YouTube < Base
      url_regex %r!\Ahttp://(?:www|jp)\.youtube\.com/watch.*[?&]v=([[:alnum:]]+)!

      private
      def login
        uri = URI.parse(@page_url)
        page = agent.get("#{uri.scheme}://#{uri.host}/login")
        login_form = page.forms.with.name('loginForm').first
        login_form.username = @opt[:you_tube_username]
        login_form.password = @opt[:you_tube_password]
        agent.submit(login_form)
      end

      def pass_verify_age
        uri = URI.parse(@page_url)
        page = agent.get(uri)
        if page.uri.path =~ /verify_age/
          login
          page = agent.post(page.uri,
                            'next_url' => "#{uri.path}?#{uri.query}",
                            'action_confirm' => 'Confirm Birth Date')
        end
        page
      end

      def scrape
        page = pass_verify_age
        @title = page.root.at('//head/title').inner_html.sub(/^YouTube[\s-]*/, '') rescue ''
        @embed_tag = page.root.at('//input[@id="embed_code"]').attributes['value'] rescue nil
        page.root.search('//script').each do |script|
          if m = script.inner_html.match(/var\s+swfArgs\s*=\s*([^;]+);/)
            swf_args = JSON::parse(m[1])
            uri = URI.parse(@page_url)
            uri.path = '/get_video'
            uri.query = "video_id=#{swf_args['video_id']}&t=#{swf_args['t']}"
            @video_url = uri.to_s
            @thumb_url = "http://i.ytimg.com/vi/#{swf_args['video_id']}/default.jpg"
          end
        end
        raise FileNotFound, 'file not found' if @video_url.nil?
      end
    end
  end
end
