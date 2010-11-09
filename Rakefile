#-*- mode: ruby; -*-
#
#                                                  Rakefile for Sekka
# Release Engineering
#   1. edit the VERSION.yml file
#   2. rake check
#   3. rake gemspec  &&   rake build
#      to generate sekka-x.x.x.gem
#   4. install sekka-x.x.x.gem to clean environment and test
#   5. rake release
#   6. gem push pkg/sekka-x.x.x.gem   ( need gem version 1.3.6 or higer. Please "gem update --system" to update )

require 'rake'
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "sekka"
    gemspec.summary = "Sekka is a SKK like input method."
    gemspec.description = "Sekka is a SKK like input method."
    gemspec.email = "kiyoka@sumibi.org"
    gemspec.homepage = "http://github.com/kiyoka/sekka"
    gemspec.authors = ["Kiyoka Nishiyama"]
    gemspec.files = FileList['lib/*.rb',
                             'lib/*.ru',
                             'lib/*.nnd',
                             'bin/*',
                             'test/*',
                             'emacs/*.el'].to_a
    gemspec.add_development_dependency "rspec"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :check do
  sh "/bin/rm -f test.record"
  sh "echo > test.log"
  files = []
  files << "./test/util.nnd"
  files << "./test/roman-lib.nnd"
  files << "./test/jisyo.nnd" 
  files << "./test/henkan-main.nnd  tokyocabinet"
  files << "./test/approximate-bench.nnd  memcache"
  files.each {|filename|
    sh  sprintf( "time ruby -I ./lib /usr/local/bin/nendo %s", filename )
  }
  sh "cat test.record" 
end

task :jisyo do
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.S.201001    >  ./data/SEKKA-JISYO.S.201001"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.hira-kata >> ./data/SEKKA-JISYO.S.201001"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.201008    >  ./data/SEKKA-JISYO.L.201008"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.hira-kata >> ./data/SEKKA-JISYO.L.201008"
end

task :load do
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.S.201001 ./data/SEKKA-JISYO.S.201001.tch"
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.L.201008 ./data/SEKKA-JISYO.L.201008.tch"
end

task :load_memcachedb do
#  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.S.201001 localhost:11211"
#  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.S.201001 localhost:21201"
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.L.201008 localhost:21201"
end

task :dump do
  sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.S.201001 > ./data/SEKKA-JISYO.S.201001.dump"
  sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.L.201008 > ./data/SEKKA-JISYO.L.201008.dump"
end

task :rackup do
  # how to install mongrel is "gem install mongrel --pre"
  sh "rackup --server mongrel --port 12929 ./lib/sekka.ru"
end

task :katakanago do
  sh "nkf --euc ./data/SKK-JISYO.L.201008 > tmpfile.euc"
  sh "/usr/share/skktools/filters/abbrev-convert.rb -k tmpfile.euc | skkdic-expr2 | iconv -f=EUC-JP -t=UTF-8 > ./data/SKK-JISYO.L.hira-kata"
  sh "/bin/rm -f tmpfile.euc"
end


task :geminstall do
  arr = [ "eventmachine",
          "fuzzy-string-match",
          "jeweler",
          "memcache-client",
          "mongrel --pre",
          "nendo",
          "rack",
          "rspec",
          "rubyforge",
          "tokyocabinet" ]
  arr.each { |str|
    sh sprintf( "gem install %s", str)
  }
end
