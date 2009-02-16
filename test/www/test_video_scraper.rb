# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../test_helper'

class TestVideoScraper < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
  end

  def teardown
    FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_configure
    WWW::VideoScraper.options = {}

    assert_nil WWW::VideoScraper.options[:cache]
    assert_nil WWW::VideoScraper.options[:logger]

    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
      conf[:logger] = Logger.new(STDOUT)
    end

    assert_kind_of FileCache, WWW::VideoScraper.options[:cache]
    assert_kind_of Logger, WWW::VideoScraper.options[:logger]
  end

  def test_find_module
    mod = WWW::VideoScraper.find_module('http://jp.youtube.com/watch?v=Ym20IwIUbuU')
    assert_equal WWW::VideoScraper::YouTube, mod
    mod = WWW::VideoScraper.find_module('http://www.nicovideo.jp/watch/sm1175788')
    assert_equal WWW::VideoScraper::NicoVideo, mod
  end

  def test_scrape
    mod = WWW::VideoScraper.find_module('http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv')
    assert_equal WWW::VideoScraper::YourFileHost, mod
    vs = WWW::VideoScraper.scrape('http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv')
    assert_kind_of WWW::VideoScraper::YourFileHost, vs
  end
end

