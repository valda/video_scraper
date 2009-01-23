# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestTube8 < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::Tube8.scrape('http://www.tube8.com/anal/alexis-amore-pov/56983/', default_opt)
    assert_equal 'http://www.tube8.com/anal/alexis-amore-pov/56983/', vs.page_url
    assert_match %r|http://media\w+\.tube8\.com/flv/[[:alnum:]]{32}/[[:alnum:]]{8}/\d{4}/\d{2}/[[:alnum:]]+/[[:alnum:]]+\.flv|, vs.video_url
    assert_equal 'http://www.tube8.com/vs/83/56983.jpg', vs.thumb_url
    assert_equal 'Alexis Amore POV', vs.title
    assert_match %r!http://mobile\d+\.tube8\.com/flv/[[:alnum:]]{32}/[[:alnum:]]{8}/\d{4}/\d{2}/[[:alnum:]]+/[[:alnum:]]+\.3gp!, vs.video_url_3gp
  end
end
