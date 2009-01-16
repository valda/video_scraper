# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestNicoVideo < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end
  end

  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_scrape
    vs = WWW::VideoScraper.scrape('http://www.nicovideo.jp/watch/sm2909967',
                                  :nico_video_mail => 'gyouzanoohsyou@hotmail.com',
                                  :nico_video_password => 'gyouzanoohsyou')
    assert_equal 'http://www.nicovideo.jp/watch/sm2909967', vs.page_url
    assert_match %r|http://smile-[[:alnum:]]+\.nicovideo\.jp/smile\?v=\d{7}\.\d{5}|, vs.video_url
    assert_match %r|http://tn-skr\d+\.smilevideo\.jp/smile\?i=\d{7}|, vs.thumb_url
    assert_match %r|^<iframe\s+.*</iframe>$|, vs.embed_tag
  end
end
