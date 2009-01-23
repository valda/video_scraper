# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestYouPorn < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::YouPorn.scrape('http://youporn.com/watch/93495?user_choice=Enter', default_opt)
    assert_equal 'http://youporn.com/watch/93495?user_choice=Enter', vs.page_url
    assert_match %r|http://download\.youporn\.com/download/\d+/flv/\d+_.*\.flv.*|, vs.video_url
    assert_match %r|http://ss-\d+\.youporn\.com/screenshot/\d+/\d+/screenshot/\d+_large\.jpg|, vs.thumb_url
    assert_equal 'unbelievable Handjob!', vs.title
  end
end
