# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestYourFileHost < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv')
    assert_equal 'http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv', vs.page_url
    assert_match %r|http://cdn\w*\.yourfilehost\.com/unit1/flash8/\d+/[[:alnum:]]{32}\.flv|, vs.video_url
    assert_match %r|http://cdn\w*\.yourfilehost\.com/thumbs/\d+/[[:alnum:]]{32}\.jpg|, vs.thumb_url
    assert_equal 'XV436__03.wmv', vs.title
  end
end
