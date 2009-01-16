# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestNicoVideo < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end
    config = Pit.get('nicovideo.jp', :require => {
                       'mail' => 'your email in nicovideo.jp',
                       'password' => 'your password in nicovideo.jp'
                     })
    @opt = { :nico_video_mail => config['mail'], :nico_video_password => config['password'] }
  end

  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_scrape
    vs = WWW::VideoScraper.scrape('http://www.nicovideo.jp/watch/sm1175788', @opt)
    assert_equal 'http://www.nicovideo.jp/watch/sm1175788', vs.page_url
    assert_match %r|http://smile-[[:alnum:]]+\.nicovideo\.jp/smile\?v=\d{7}\.\d{5}|, vs.video_url
    assert_match %r|http://tn-skr\d+\.smilevideo\.jp/smile\?i=\d{7}|, vs.thumb_url
    assert_match %r|^<iframe\s+.*</iframe>$|, vs.embed_tag
    assert_equal '本格的 ガチムチパンツレスリング', vs.title
  end
end
