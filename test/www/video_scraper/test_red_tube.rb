# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestRedTube < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::RedTube.scrape('http://www.redtube.com/8415', default_opt)
    assert_equal 'http://www.redtube.com/8415', vs.page_url
    assert_match %r!http://dl\.redtube\.com/_videos_t4vn23s9jc5498tgj49icfj4678/0000008/Z2XDJA1ZL\.flv!, vs.video_url
    assert_nil vs.thumb_url
    assert_match %r!<object\s+.*</object>!, vs.embed_tag
  end
end
