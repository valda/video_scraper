# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestMoroTube < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::MoroTube.scrape('http://www.morotube.com/watch.php?clip=46430e1d', default_opt)
    assert_equal 'http://www.morotube.com/watch.php?clip=46430e1d', vs.page_url
    assert_match %r!http://video\d+\.morotube\.com/[[:alnum:]]{32}/[[:alnum:]]{8}/[[:alnum:]]{8}\.flv!, vs.video_url
    assert_match %r!http://static\d+\.morotube\.com/thumbs/\w{8}\.jpg!, vs.thumb_url
    assert_match %r!^<embed\s.*</embed>$!, vs.embed_tag
  end
end
