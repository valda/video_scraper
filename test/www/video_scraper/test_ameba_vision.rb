# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestAmebaVision < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://vision.ameba.jp/watch.do?movie=772341')
    assert_equal 'http://vision.ameba.jp/watch.do?movie=772341', vs.page_url
    assert_match %r|http://[-[:alnum:]]+\.vision\.ameba\.jp/flv/\d{4}/\d{2}/\d{2}/[[:alnum:]]+\.flv|, vs.video_url
    assert_match %r|http://[-[:alnum:]]+\.vision\.ameba\.jp/jpg/\d{4}/\d{2}/\d{2}/[[:alnum:]]+_4\.jpg|, vs.thumb_url
  end
end
