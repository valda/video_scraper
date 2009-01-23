# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestPornotube < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::Pornotube.scrape('http://pornotube.com/media.php?m=1677937', default_opt)
    assert_equal 'http://pornotube.com/media.php?m=1677937', vs.page_url
    assert_match %r|http://video\d+\.pornotube\.com/\d+/\d+\.flv|, vs.video_url
    assert_match %r|http://photo\.pornotube\.com/thumbnails/video/\d+/\d+\.jpg|, vs.thumb_url
    assert_match %r|^<embed\s+src=\".*\"\s*/>$|, vs.embed_tag
  end

  def test_scrape_alt_url
    vs = WWW::VideoScraper::Pornotube.scrape('http://pornotube.com/channels.php?channelId=83&m=1677912', default_opt)
    assert_equal 'http://pornotube.com/channels.php?channelId=83&m=1677912', vs.page_url
    assert_match %r|http://video\d+\.pornotube\.com/\d+/\d+\.flv|, vs.video_url
    assert_match %r|http://photo\.pornotube\.com/thumbnails/video/\d+/\d+\.jpg|, vs.thumb_url
    assert_match %r|^<embed\s+src=\".*\"\s*/>$|, vs.embed_tag
  end
end
