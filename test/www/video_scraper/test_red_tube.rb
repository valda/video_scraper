# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestRedTube < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::RedTube.scrape('http://www.redtube.com/15021', default_opt)
    assert_equal 'http://www.redtube.com/15021', vs.page_url
    assert_equal 'http://dl.redtube.com/_videos_t4vn23s9jc5498tgj49icfj4678/0000015/X6KKXB0DB.flv', vs.video_url
    assert_equal 'http://thumbs.redtube.com/_thumbs/0000015/0015021/0015021_001.jpg', vs.thumb_url
    assert_match %r!<object\s+.*</object>!, vs.embed_tag
  end
end
