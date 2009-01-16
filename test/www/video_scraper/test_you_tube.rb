# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestYouTube < Test::Unit::TestCase
  def setup
    @cache_root = '/tmp/test_video_scraper_cache'
    WWW::VideoScraper.configure do |conf|
      conf[:cache] = FileCache.new('TestVideoScraper', @cache_root, 60*60*24)
    end

    config = Pit.get('youtube.com', :require => {
                       'username' => 'your email in youtube.com',
                       'password' => 'your password in youtube.com'
                     })
    @opt = { :you_tube_username => config['username'], :you_tube_password => config['password'] }
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
