# -*- mode:ruby; coding:utf-8 -*-

require File.dirname(__FILE__) + '/../../test_helper'

class TestBase < Test::Unit::TestCase
  def test_nulllogger
    logger = WWW::VideoScraper::NullLogger.new
    assert_nil logger.fatal 'nop'
    assert_nil logger.error 'nop'
    assert_nil logger.warn 'nop'
    assert_nil logger.info 'nop'
    assert_nil logger.debug 'nop'
  end
end
