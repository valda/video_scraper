# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestTube8 < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
      conf[:logger] = Logger.new(STDOUT)
    end
  end

  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_scrape
    vs = WWW::VideoScraper.scrape('http://www.tube8.com/anal/alexis-amore-pov/56983/')
    assert_equal 'http://www.tube8.com/anal/alexis-amore-pov/56983/', vs.page_url
    assert_match %r|http://medianl\d+\.tube8\.com/flv/[[:alnum:]]{32}/[[:alnum:]]{8}/\d{4}/\d{2}/[[:alnum:]]+/[[:alnum:]]+\.flv|, vs.video_url
    assert_equal 'http://www.tube8.com/vs/83/56983.jpg', vs.thumb_url
    assert_equal 'Alexis Amore POV', vs.title
  end
end
