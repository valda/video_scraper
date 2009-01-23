# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestNicoVideo < Test::Unit::TestCase
  def setup
    config = Pit.get('nicovideo.jp', :require => {
                       'mail' => 'your email in nicovideo.jp',
                       'password' => 'your password in nicovideo.jp'
                     })
    default_opt.merge!(:nico_video_mail => config['mail'],
                       :nico_video_password => config['password'])
  end

  def test_scrape
    vs = WWW::VideoScraper::NicoVideo.scrape('http://www.nicovideo.jp/watch/sm1175788', default_opt)
    assert_equal 'http://www.nicovideo.jp/watch/sm1175788', vs.page_url
    assert_match %r|http://smile-[[:alnum:]]+\.nicovideo\.jp/smile\?v=\d{7}\.\d{5}|, vs.video_url
    assert_match %r|http://tn-skr\d+\.smilevideo\.jp/smile\?i=\d{7}|, vs.thumb_url
    assert_match %r|^<iframe\s+.*</iframe>$|, vs.embed_tag
    assert_equal '本格的 ガチムチパンツレスリング', vs.title
  end
end
