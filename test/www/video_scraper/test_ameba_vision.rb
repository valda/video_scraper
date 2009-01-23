# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestAmebaVision < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::AmebaVision.scrape('http://vision.ameba.jp/watch.do?movie=772341', default_opt)
    assert_equal 'http://vision.ameba.jp/watch.do?movie=772341', vs.page_url
    assert_match %r|http://[-[:alnum:]]+\.vision\.ameba\.jp/flv/\d{4}/\d{2}/\d{2}/[[:alnum:]]+\.flv|, vs.video_url
    assert_match %r|http://[-[:alnum:]]+\.vision\.ameba\.jp/jpg/\d{4}/\d{2}/\d{2}/[[:alnum:]]+_4\.jpg|, vs.thumb_url
  end
end
