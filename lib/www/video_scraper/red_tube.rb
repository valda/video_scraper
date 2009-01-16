require 'video_scraper'
require 'open-uri'
require 'hpricot'
require 'cgi'

module VideoScraper
  class RedTube
    attr_reader :page_url, :video_url

    def initialize(opt)
      @opt = opt.is_a?(String) ? { :url => opt } : opt
      do_query
    end

    def self.valid_url?(url)
      url =~ %r|\Ahttp://www\.redtube\.com/\d{4}|
    end

    def embed_tag
      return '' if @id.nil?
      return @embed_tag if @embed_tag
      url = "http://www.redtube.com/embed/#{@id}"
      open_opt = { 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)' }
      response_body = open(url, open_opt) { |res| res.read }
      doc = Hpricot(response_body)
      doc.search('//textarea#cpf') do |elem|
        @embed_tag = elem.inner_html
      end
      @embed_tag
    end

    private
    def do_query
      url = @opt[:url]
      raise StandardError, 'url param is requred' unless url
      raise StandardError, "url is not RedTube link: #{url}" unless RedTube.valid_url? url
      @id = url.match(%r|www\.redtube\.com/(\d{4})|)[1]
      s = @id || '0'
      s = '1' if s.empty?
      pathnr = s.to_i / 1000
      s = "%07d" % s.to_i
      pathnr = "%07d" % pathnr
      xc = %w[R 1 5 3 4 2 O 7 K 9 H B C D X F G A I J 8 L M Z 6 P Q 0 S T U V W E Y N]
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
      @page_url = "http://www.redtube.com/#{@id}"
      @video_url = "http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/#{content_video}"
      #"http://thumbs.redtube.com/_thumbs/#{pathnr}/#{s}/#{s}_#{'%03d' % i}.jpg"
    end
  end
end

if $0 == __FILE__
  w = VideoScraper::RedTube.new('http://www.redtube.com/8415')
  puts w.page_url
  puts "got:    #{w.video_url}"
  puts 'expect: http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/0000008/Z2XDJA1ZL.flv'
  puts w.embed_tag
end
