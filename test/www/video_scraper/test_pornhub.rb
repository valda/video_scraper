# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestPornhub < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::Pornhub.scrape('http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0', default_opt)
    assert_equal 'http://www.pornhub.com/view_video.php?viewkey=27f115e7fee8c18f92b0', vs.page_url
    assert_match %r|http://media1.pornhub.com/dl/[[:alnum:]]{32}/[[:alnum:]]{8}/videos/000/191/743/191743\.flv|, vs.video_url
    assert_equal 'http://p1.pornhub.com/thumbs/000/191/743/small.jpg', vs.thumb_url
    assert_match %r|^<object type=\"application/x-shockwave-flash\" data=\".*</object>$|, vs.embed_tag
    assert_equal 'Liliane Tiger and Jane Darling to hot to handle', vs.title
  end
end
