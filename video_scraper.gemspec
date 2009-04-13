# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{video_scraper}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["YAMAGUCHI Seiji"]
  s.date = %q{2009-02-16}
  s.description = %q{Web scraping library for video sharing sites.}
  s.email = %q{valda@underscore.jp}
  s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["README", "ChangeLog", "Rakefile", "test/test_helper.rb", "test/www", "test/www/video_scraper", "test/www/video_scraper/test_ameba_vision.rb", "test/www/video_scraper/test_dailymotion.rb", "test/www/video_scraper/test_age_sage.rb", "test/www/video_scraper/test_pornotube.rb", "test/www/video_scraper/test_tube8.rb", "test/www/video_scraper/test_your_file_host.rb", "test/www/video_scraper/test_moro_tube.rb", "test/www/video_scraper/test_eic_book.rb", "test/www/video_scraper/test_veoh.rb", "test/www/video_scraper/test_pornhub.rb", "test/www/video_scraper/test_nico_video.rb", "test/www/video_scraper/test_you_porn.rb", "test/www/video_scraper/test_you_tube.rb", "test/www/video_scraper/test_adult_satellites.rb", "test/www/video_scraper/test_red_tube.rb", "test/www/video_scraper/test_base.rb", "test/www/test_video_scraper.rb", "lib/www", "lib/www/video_scraper", "lib/www/video_scraper/nico_video.rb", "lib/www/video_scraper/you_porn.rb", "lib/www/video_scraper/ameba_vision.rb", "lib/www/video_scraper/age_sage.rb", "lib/www/video_scraper/eic_book.rb", "lib/www/video_scraper/pornotube.rb", "lib/www/video_scraper/adult_satellites.rb", "lib/www/video_scraper/you_tube.rb", "lib/www/video_scraper/moro_tube.rb", "lib/www/video_scraper/pornhub.rb", "lib/www/video_scraper/dailymotion.rb", "lib/www/video_scraper/veoh.rb", "lib/www/video_scraper/red_tube.rb", "lib/www/video_scraper/base.rb", "lib/www/video_scraper/your_file_host.rb", "lib/www/video_scraper/tube8.rb", "lib/www/video_scraper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/valda/video_scraper}
  s.rdoc_options = ["--title", "video_scraper documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{video_scraper}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Web scraping library for video sharing sites.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, [">= 0.8.4"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6.164"])
    else
      s.add_dependency(%q<mechanize>, [">= 0.8.4"])
      s.add_dependency(%q<hpricot>, [">= 0.6.164"])
    end
  else
    s.add_dependency(%q<mechanize>, [">= 0.8.4"])
    s.add_dependency(%q<hpricot>, [">= 0.6.164"])
  end
end
