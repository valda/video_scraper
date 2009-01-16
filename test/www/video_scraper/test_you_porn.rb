# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestYouPorn < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://youporn.com/watch/93495?user_choice=Enter')
    assert_equal 'http://youporn.com/watch/93495?user_choice=Enter', vs.page_url
    assert_match %r|http://download\.youporn\.com/download/\d+/flv/\d+_.*\.flv.*|, vs.video_url
    assert_match %r|http://ss-\d+\.youporn\.com/screenshot/\d+/\d+/screenshot/\d+_large\.jpg|, vs.thumb_url
    assert_equal 'unbelievable Handjob!', vs.title
  end
end
