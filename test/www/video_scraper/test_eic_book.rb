# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class EicBook < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::EicBook.scrape('http://www.eic-book.com/detail_12759.html', default_opt)
    assert_equal 'http://www.eic-book.com/detail_12759.html', vs.page_url
    assert_equal 'http://flv.idol-mile.com/book/12759.flv', vs.video_url
    assert_equal 'http://www.eic-book.com/img/product/h4/pp_12759.jpg', vs.thumb_url
    assert_equal '藤木あやか  DVD 「お蔵入り寸前！藤木あやか A面」', vs.title
    assert_equal 24, vs.capture_urls.count
  end
end

