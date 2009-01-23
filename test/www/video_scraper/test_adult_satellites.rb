# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestAdultSatellites < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::AdultSatellites.scrape('http://www.asa.tv/movie_detail.php?userid=&movie_id=15680', default_opt)
    assert_equal 'http://www.asa.tv/movie_detail.php?userid=&movie_id=15680', vs.page_url
    assert_match %r|http://asa\.tv/movie/D5/gcuppapa/[[:alnum:]]{32}\.flv|, vs.video_url
    assert_match %r|http://www\.asa\.tv/captured/gcuppapa/[[:alnum:]]{32}_1\.jpg|, vs.thumb_url
    assert_equal '妃乃ひかり,2', vs.title
  end
end
