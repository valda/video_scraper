# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestVeoh < Test::Unit::TestCase
  def test_scrape
    vs = WWW::VideoScraper::Veoh.scrape('http://www.veoh.com/videos/v6245232rh8aGEM9', default_opt)
    assert_equal 'http://www.veoh.com/videos/v6245232rh8aGEM9', vs.page_url
    assert_match %r|http://content\.veoh\.com/flash/p/\d/[[:alnum:]]{16}/[[:alnum:]]{40}\.fll\?ct=[[:alnum:]]{48}|, vs.video_url
    assert_match %r|http://p-images\.veoh\.com/image\.out\?imageId=media-[[:alnum:]]+.jpg|, vs.thumb_url
    assert_match %r|^<embed\s.*>$|, vs.embed_tag
  end

  def test_canonical_url
    vs = WWW::VideoScraper::Veoh.scrape('http://www.veoh.com/collection/maysaku/watch/v19937773gwSJPMk', default_opt)
    assert_equal 'http://www.veoh.com/videos/v19937773gwSJPMk', vs.page_url
    vs = WWW::VideoScraper::Veoh.scrape('http://www.veoh.com/collection/maysaku/watch/v19937773gwSJPMk#watch%3Dv16112008KGD7Pg2n', default_opt)
    assert_equal 'http://www.veoh.com/videos/v16112008KGD7Pg2n', vs.page_url
    vs = WWW::VideoScraper::Veoh.scrape('http://www.veoh.com/videos/v19937773gwSJPMk?rank=0&jsonParams=%7B%22numResults%22%3A20%2C%22rlmin%22%3A0%2C%22query%22%3A%22Shaman+King+01%22%2C%22rlmax%22%3Anull%2C%22veohOnly%22%3Atrue%2C%22order%22%3A%22default%22%2C%22range%22%3A%22a%22%2C%22sId%22%3A%22192998624295114150%22%7D&searchId=192998624295114150&rank=1', default_opt)
    assert_equal 'http://www.veoh.com/videos/v19937773gwSJPMk', vs.page_url
  end
end
