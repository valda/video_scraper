# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestYourFileHost < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::YourFileHost.scrape('http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv', default_opt)
    assert_equal 'http://www.yourfilehost.com/media.php?cat=video&file=XV436__03.wmv', vs.page_url
    assert_match %r|http://cdn\w*\.yourfilehost\.com/unit1/flash8/\d+/[[:alnum:]]{32}\.flv|, vs.video_url
    assert_match %r|http://cdn\w*\.yourfilehost\.com/thumbs/\d+/[[:alnum:]]{32}\.jpg|, vs.thumb_url
    assert_equal 'XV436__03.wmv', vs.title
  end
end

