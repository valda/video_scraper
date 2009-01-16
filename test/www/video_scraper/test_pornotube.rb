# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestPornotube < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://pornotube.com/media.php?m=1677937')
    assert_equal 'http://pornotube.com/media.php?m=1677937', vs.page_url
    assert_match %r|http://video\d+\.pornotube\.com/\d+/\d+\.flv|, vs.video_url
    assert_match %r|http://photo\.pornotube\.com/thumbnails/video/\d+/\d+\.jpg|, vs.thumb_url
    assert_match %r|^<embed\s+src=\".*\"\s*/>$|, vs.embed_tag
  end

  def test_scrape_alt_url
    vs = WWW::VideoScraper.scrape('http://pornotube.com/channels.php?channelId=83&m=1677912')
    assert_equal 'http://pornotube.com/channels.php?channelId=83&m=1677912', vs.page_url
    assert_match %r|http://video\d+\.pornotube\.com/\d+/\d+\.flv|, vs.video_url
    assert_match %r|http://photo\.pornotube\.com/thumbnails/video/\d+/\d+\.jpg|, vs.thumb_url
    assert_match %r|^<embed\s+src=\".*\"\s*/>$|, vs.embed_tag
  end
end
