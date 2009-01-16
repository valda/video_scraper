# -*- mode:ruby; coding:utf-8 -*-

Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'video_scraper', '*.rb')).each do |lib|
  require lib
end
