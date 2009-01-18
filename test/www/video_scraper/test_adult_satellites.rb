# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestAdultSatellites < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://www.asa.tv/movie_detail.php?userid=&movie_id=15680')
    assert_equal 'http://www.asa.tv/movie_detail.php?userid=&movie_id=15680', vs.page_url
    assert_match %r|http://asa\.tv/movie/D5/gcuppapa/[[:alnum:]]{32}\.flv|, vs.video_url
    assert_match %r|http://www\.asa\.tv/captured/gcuppapa/[[:alnum:]]{32}_1\.jpg|, vs.thumb_url
    assert_equal '妃乃ひかり,2', vs.title
  end
end
