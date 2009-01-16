# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestPornhub < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end     
  end
  
  def teardown
    # FileUtils.remove_entry_secure(@cache_root, true)
  end

  def test_pornhub
    vs = WWW::VideoScraper.scrape('http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0')
    assert_equal 'http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0', vs.page_url
    assert_match %r|http://media1.pornhub.com/dl/[[:alnum:]]{32}/[[:alnum:]]{8}/videos/000/191/743/191743\.flv|, vs.video_url
    assert_equal 'http://p1.pornhub.com/thumbs/000/191/743/small.jpg', vs.thumb_url
    assert_match %r|^<object type=\"application/x-shockwave-flash\" data=\".*</object>$|, vs.embed_tag
  end
end
