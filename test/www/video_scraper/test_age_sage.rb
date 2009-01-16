# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../../lib'))
require 'www/video_scraper'
require 'filecache'
require 'fileutils'

class TestAgeSage < Test::Unit::TestCase
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
    vs = WWW::VideoScraper.scrape('http://adult.agesage.jp/contentsPage.html?mcd=oadyChZgcoN9rqbJ')
    assert_equal 'http://adult.agesage.jp/contentsPage.html?mcd=oadyChZgcoN9rqbJ', vs.page_url
    assert_match %r!http://file\d+\.agesage\.jp/flv/\d{8}/\d{10}_\d{6}\.flv!, vs.video_url
    assert_match %r!http://file\d+\.agesage\.jp/data/\d{8}/\d{10}_\d{6}!, vs.thumb_url
    assert_match %r!^<script type=\"text/javascript\" src=\".*</script>$!, vs.embed_tag
  end
end
