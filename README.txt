= VideoScraper

* FIX (url)

== DESCRIPTION:

Web scraping library for video sharing sites.

== FEATURES/PROBLEMS:

Supported sites

* Youtube
* Niconico Douga
* Ameba Vision
* Daily Motion
* Veoh
* YourFileHost
* RedTube
* Pornhub
* Ura Agesage
* MoroTube
* Pornotube
* Youporn

== SYNOPSIS:

   require 'video_scraper'
   scraper = VideoScraper::scrape('http://www.youtube.com/watch?v=OFPnvARUOHI&feature=dir')
   scraper.video_url
   >> expect: "http://www.youtube.com/get_video?video_id=OFPnvARUOHI&t=OEgsToPDskIpQJU48rm4-sS1RtbItouY"
   scraper.thumb_url
   >> expect: "http://i.ytimg.com/vi/OFPnvARUOHI/default.jpg"
   
== REQUIREMENTS:

* WWW::Mechanize
* Hpricot

== INSTALL:

* FIX (sudo gem install, anything else)

== LICENSE:

(The MIT License)

Copyright (c) 2008 YAMAGUCHI Seiji <valda at underscore.jp>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
