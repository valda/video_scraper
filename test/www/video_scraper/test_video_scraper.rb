# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestVideoScraper < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
  end
  
  def teardown
    FileUtils.remove_entry_secure(@cache_root, true)
  end
  
  def test_configure
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end
    assert_kind_of FileCache, WWW::VideoScraper.options[:cache]
  end
end
