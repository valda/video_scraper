# -*- mode:ruby; coding:utf-8 -*-

require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../lib/www/video_scraper')

require 'fileutils'
require 'filecache'
require 'logger'
require 'pit'

class Test::Unit::TestCase
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def filecache
    @filecache ||= FileCache.new('TestVideoScraper', '/tmp/test_video_scraper_cache', 60 * 60)
  end

  def default_opt
    @default_opt ||= { :logger => logger, :cache => filecache }
  end
end
