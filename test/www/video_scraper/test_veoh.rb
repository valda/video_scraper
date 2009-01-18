# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestVeoh < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://www.veoh.com/videos/v6245232rh8aGEM9')
    assert_equal 'http://www.veoh.com/videos/v6245232rh8aGEM9', vs.page_url
    assert_match %r|http://content\.veoh\.com/flash/p/\d/[[:alnum:]]{16}/[[:alnum:]]{40}\.fll\?ct=[[:alnum:]]{48}|, vs.video_url
    assert_match %r|http://p-images\.veoh\.com/image\.out\?imageId=media-[[:alnum:]]+.jpg|, vs.thumb_url
    assert_match %r|^<embed\s.*>$|, vs.embed_tag
  end
end
