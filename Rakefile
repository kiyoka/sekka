# -*- mode: ruby; -*-
#                                                  Rakefile for Sekka
# Release Engineering
#   1. edit the VERSION.yml file
#   2. rake compile  &&   rake test
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
    gemspec.description = "Sekka is a SKK like input method. Sekka server provides REST Based API. If you are SKK user, let's try it."
    gemspec.email = "kiyoka@sumibi.org"
    gemspec.homepage = "http://github.com/kiyoka/sekka"
    gemspec.authors = ["Kiyoka Nishiyama"]
    gemspec.files = FileList['README',
                             'COPYING',
                             'lib/*.rb',
                             'lib/*.ru',
                             'lib/sekka/*.rb',
                             'lib/sekka/*.nnd',
                             'bin/sekka-jisyo',
                             'bin/sekka-server',
                             'bin/sekka-benchmark',
                             'bin/sekka-path',
                             'test/*.nnd',
                             'test/*.rb',
                             'script/sekkaserver.*',
                             'emacs/*.el'].to_a
    gemspec.executables = ["sekka-jisyo",
                           "sekka-server",
                           "sekka-benchmark",
                           "sekka-path"]
    gemspec.add_development_dependency "rubyforge"
    gemspec.required_ruby_version = '>= 1.9.1'
    gemspec.add_dependency( "eventmachine" )
    gemspec.add_dependency( "fuzzy-string-match" )
    gemspec.add_dependency( "jeweler" )
    gemspec.add_dependency( "memcache-client" )
    gemspec.add_dependency( "nendo", "= 0.5.1" )
    gemspec.add_dependency( "rack" )
    gemspec.add_dependency( "tokyocabinet" )
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :compile do
  # generate version.rb
  vh = Jeweler::VersionHelper.new "."
  open( "./lib/sekka/sekkaversion.rb", "w" ) {|f|
    f.puts(   "class SekkaVersion" )
    f.puts(   "  include Singleton" )
    f.puts(   "  def self.version" )
    f.printf( "    \"%s\"\n", vh )
    f.puts(   "  end" )
    f.puts(   "end" )
  }

  # Replace Version Number
  targetFile = "./emacs/sekka.el"
  vh = Jeweler::VersionHelper.new "."
  (original, modified) = open( targetFile, "r:utf-8" ) {|f|
    lines = f.readlines
    [ lines,
      lines.map {|line|
        if line.match( /;;SEKKA-VERSION/ )
          sprintf( '  "%s" ;;SEKKA-VERSION', vh.to_s ) + "\n"
        else
          line
        end
      } ]
  }
  if original.join != modified.join
    puts "Info: " + targetFile + " was updated."
    open( targetFile, "w" ) {|f|
      f.write( modified.join )
    }
  end
end

task :test do
  sh "/bin/rm -f test.record"
  files = []
  files << "./test/util.nnd"
  files << "./test/alphabet-lib.nnd"
  files << "./test/sharp-number.nnd"
  files << "./test/roman-lib.nnd"
  files << "./test/azik-verification.nnd"
  files << "./test/jisyo.nnd"
  files << "./test/google-ime.nnd"
  files << "./test/henkan-main.nnd  tokyocabinet"
  files << "./test/memcache.nnd"
  files.each {|filename|
    sh  sprintf( "time ruby -I ./lib /usr/local/bin/nendo %s", filename )
  }
  sh "cat test.record"
end

task :alljisyo => [ :jisyoS, :jisyoL, :loadS, :loadL ]

task :jisyoS do
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.201008           >  ./data/SEKKA-JISYO.SMALL"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.SMALL"
end

task :jisyoL do
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.201008           >  ./data/SEKKA-JISYO.LARGE"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.LARGE"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.fullname           >> ./data/SEKKA-JISYO.LARGE"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.jinmei             >> ./data/SEKKA-JISYO.LARGE"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.station            >> ./data/SEKKA-JISYO.LARGE"
end

task :loadS do
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.SMALL ./data/SEKKA-JISYO.SMALL.tch"
end

task :loadL do
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.LARGE ./data/SEKKA-JISYO.LARGE.tch"
end

task :dump do
  sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.SMALL.tch > ./data/SEKKA-JISYO.SMALL.dump"
  sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.LARGE.tch > ./data/SEKKA-JISYO.LARGE.dump"
end


task :phrase do
#  sh "/bin/cp ./data/6gm-0000.txt ./data/head.txt"
#  sh "time ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase.nnd ./data/head.txt > ./data/log"
  sh "awk '{ print $1; }' ./data/log | sort | uniq > ./data/hiragana_list.txt"
end

task :rackup do
  # how to install mongrel is "gem install mongrel --pre"
  sh "ruby -I ./lib ./bin/sekka-server"
end

task :rackup_nohup do
  sh "nohup ruby -I ./lib ./bin/sekka-server > ./rackup.log &"
  sh "sleep 3"
  sh "tail -f ./rackup.log"
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
