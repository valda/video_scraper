# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestYouTube < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end

    #require 'yaml'
    #y = YAML.load_file(File.join(ENV['HOME'], '.videoscraperrc'))
    #VideoScraper::YouTube.configure do |conf|
    #  conf[:mail] = y['youtube']['mail']
    #  conf[:password] = y['youtube']['password']
    #end
    @opt = { :you_tube_username => 'gyouzanoohsyou', :you_tube_password => 'ahoahoman' }
  end

  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_scrape
    vs = WWW::VideoScraper.scrape('http://jp.youtube.com/watch?v=Ym20IwIUbuU', @opt)
    assert_equal 'http://jp.youtube.com/watch?v=Ym20IwIUbuU', vs.page_url
    assert_match %r|http://jp\.youtube\.com/get_video\?video_id=Ym20IwIUbuU&t=[-_[:alnum:]]{32}|, vs.video_url
    assert_match %r|http://\w\.ytimg\.com/vi/Ym20IwIUbuU/default\.jpg|, vs.thumb_url
    assert_match %r|^<object\s+.*</object>$|, vs.embed_tag
    assert_equal 'とらドラ！Toradora ep15 2-3', vs.title
  end

  def test_scrape_alt_url
    vs = WWW::VideoScraper.scrape('http://jp.youtube.com/watch?v=ibhaQZB9TWU', @opt)
    assert_equal 'http://jp.youtube.com/watch?v=ibhaQZB9TWU', vs.page_url
    assert_match %r|http://jp\.youtube\.com/get_video\?video_id=ibhaQZB9TWU&t=[-_[:alnum:]]{32}|, vs.video_url
    assert_match %r|http://\w\.ytimg\.com/vi/ibhaQZB9TWU/default\.jpg|, vs.thumb_url
    assert_match %r|^<object\s+.*</object>$|, vs.embed_tag
    assert_equal '水着の人妻', vs.title
  end
end
