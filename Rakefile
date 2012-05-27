# -*- mode: ruby; -*-
#                                                  Rakefile for Sekka
#
# Release Engineering:
#   1. edit the VERSION.yml file
#   2. rake compile  &&   rake test   &&   rake gemspec   &&   rake build
#      to generate sekka-x.x.x.gem
#   3. install sekka-x.x.x.gem to clean environment and test
#   4. rake release
#   5. gem push pkg/sekka-x.x.x.gem   ( need gem version 1.3.6 or higer. Please "gem update --system" to update )
#
# Enviroment Variables:
#   Please select from
#     DB=dbm
#     DB=tokyocabinet
#     DB=redis
#     DB=                (default)
#     DB=all             dbm/tokyocabinet/redis
#

require 'rake'
begin
  require 'jeweler2'
  Jeweler::Tasks.new do |gemspec|
    vh = Jeweler::VersionHelper.new "."
    gemspec.version = vh.to_s + ".pre"
    gemspec.name = "sekka"
    gemspec.summary = "Sekka is a SKK like input method."
    gemspec.description = "Sekka is a SKK like input method. Sekka server provides REST Based API. If you are SKK user, let's try it."
    gemspec.email = "kiyoka@sumibi.org"
    gemspec.homepage = "http://github.com/kiyoka/sekka"
    gemspec.authors = ["Kiyoka Nishiyama"]
    gemspec.files = FileList['Rakefile',
                             '.gemtest',
                             'VERSION.yml',
                             'README',
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
                             'test/*.txt',
                             'script/sekkaserver.*',
                             'emacs/*.el'].to_a
    gemspec.executables = ["sekka-jisyo",
                           "sekka-server",
                           "sekka-benchmark",
                           "sekka-path"]
    gemspec.required_ruby_version = '>= 1.9.1'
    gemspec.add_dependency( "eventmachine" )
    gemspec.add_dependency( "memcache-client" )
    gemspec.add_dependency( "nendo", "= 0.6.4" )
    gemspec.add_dependency( "distributed-trie" )
    gemspec.add_dependency( "rack" )
    gemspec.add_dependency( "ruby-progressbar" )
  end
rescue LoadError
  puts "Jeweler2 not available. Install it with: sudo gem install jeweler2"
end


task :default => [:test] do
end

task :compile do
  # generate version.rb
  dictVersion = "1.2.1"
  vh = Jeweler::VersionHelper.new "."
  open( "./lib/sekka/sekkaversion.rb", "w" ) {|f|
    f.puts(   "class SekkaVersion" )
    f.printf( "  def  self.version()     \"%s\"  end\n", vh )
    f.printf( "  def  self.dictVersion() \"%s\"  end\n", dictVersion )
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
  sh "ruby -I ./lib ./bin/sekka-path > /tmp/path1"
  path1 = open( "/tmp/path1" ) {|f|
    f.readline.chomp
  }
  path2 = File.dirname( __FILE__ )
  unless path1 == path2
    puts STDERR.printf( "Error: on <sekka-path> requires [%s] but got [%s].", path2, path1 )
    exit 1
  end

  sh "/bin/rm -f test.record test.tch"
  files = []
  files << "./test/memcache.nnd"
  files << "./test/util.nnd"
  files << "./test/alphabet-lib.nnd"
  files << "./test/sharp-number.nnd"
  files << "./test/roman-lib.nnd"
  files << "./test/azik-verification.nnd"
  files << "./test/jisyo.nnd"
  files << "./test/google-ime.nnd"
  STDERR.printf( "Info:  env DB=%s\n", ENV['DB'] )
  case ENV['DB']
  when 'dbm'
    files << "./test/henkan-main.nnd  dbm"
  when 'tokyocabinet'
    files << "./test/henkan-main.nnd  tokyocabinet"
  when 'redis'
    files << "./test/redis.nnd"
    files << "./test/henkan-main.nnd  redis"
  when 'pure'
    files << "./test/henkan-main.nnd  pure"
  when 'all'
    files << "./test/henkan-main.nnd  dbm"
    files << "./test/henkan-main.nnd  tokyocabinet"
    files << "./test/henkan-main.nnd  redis"
    files << "./test/henkan-main.nnd  pure"
  else # default
    files << "./test/henkan-main.nnd  tokyocabinet"
    files << "./test/henkan-main.nnd  pure"
  end
  files.each {|filename|
    nendopath = `which nendo`.chomp
    sh  sprintf( "time ruby -I ./lib %s %s", nendopath, filename )
  }
  sh "cat test.record"
end

task :bench do
  sh "time ruby -I ./lib /usr/local/bin/nendo ./test/approximate-bench.nnd"
  sh "time ruby -I ./lib /usr/local/bin/nendo ./test/henkan-bench.nnd"
end

task :alljisyo  => [ :alljisyoS, :alljisyoL ]
task :alljisyoS => [ :jisyoS, :loadS, :dumpS ]
task :alljisyoL => [ :jisyoL, :loadL, :dumpL ]

task :jisyoS do
  [ "N" "A" ].each {|x|
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.L.201008           >  ./data/SEKKA-JISYO.SMALL.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.SMALL.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.hiragana-phrase    >> ./data/SEKKA-JISYO.SMALL.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.hiragana-phrase2   >> ./data/SEKKA-JISYO.SMALL.#{x}"
  }
end

task :jisyoL do
  [ "N" "A" ].each {|x|
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.L.201008           >  ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.fullname           >> ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.jinmei             >> ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.station            >> ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.hiragana-phrase    >> ./data/SEKKA-JISYO.LARGE.#{x}"
    sh "time ./bin/sekka-jisyo convert#{x} ./data/SKK-JISYO.hiragana-phrase2   >> ./data/SEKKA-JISYO.LARGE.#{x}"
  }
end

task :loadS do
  [ "N", "A" ].each {|x|
    sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.SMALL.#{x}  ./data/SEKKA-JISYO.SMALL.#{x}.tch"
  }
end

task :loadL do
  [ "N", "A" ].each {|x|
    sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.LARGE.#{x}  ./data/SEKKA-JISYO.LARGE.#{x}.tch"
  }
end

task :dumpS do
  [ "N", "A" ].each {|x|
    sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.SMALL.#{x}.tch > ./data/SEKKA-JISYO.SMALL.#{x}.tsv"
  }
end

task :dumpL do
  [ "N", "A" ].each {|x|
    sh "time ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.LARGE.#{x}.tch > ./data/SEKKA-JISYO.LARGE.#{x}.tsv"
  }
end


# Fetched data from
#   http://s-yata.jp/corpus/nwc2010/ngrams/
task :phrase => [ "./data/6gm-0000.txt" ]  do
  sh "time ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase_in_webcorpus.nnd           ./data/6gm-0000.txt | sort | uniq > /tmp/tmp.txt"
  sh "time ruby -I ./lib /usr/local/bin/nendo ./data/writing_phrase_filter.nnd /tmp/tmp.txt  | sort | uniq     > ./data/SKK-JISYO.hiragana-phrase"
end

file "./data/6gm-0000.txt"  do
  sh "wget http://dist.s-yata.jp/corpus/nwc2010/ngrams/word/over999/6gms/6gm-0000.xz -O /tmp/6gm-0000.xz"
  sh "xz -cd /tmp/6gm-0000.xz > ./data/6gm-0000.txt"
end

task :phrase2 => [ "./data/ipadic.all.utf8.txt" ] do
  sh "time ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase_in_ipadic.nnd             ./data/ipadic.all.utf8.txt | sort | uniq > ./data/SKK-JISYO.hiragana-phrase2"
end

file "./data/ipadic.all.utf8.txt" do
  sh "wget http://chasen.aist-nara.ac.jp/stable/ipadic/ipadic-2.7.0.tar.gz -O /tmp/ipadic-2.7.0.tar.gz"
  sh "tar zxfC /tmp/ipadic-2.7.0.tar.gz /tmp"
  sh "iconv -f euc-jp -t utf-8 /tmp/ipadic-2.7.0/*.dic > ./data/ipadic.all.utf8.txt"
end


task :rackup do
  # how to install mongrel is "gem install mongrel --pre"
  sh "ruby -I ./lib ./bin/sekka-server"
end

task :katakanago do
  sh "nkf --euc ./data/SKK-JISYO.L.201008 > tmpfile.euc"
  sh "/usr/share/skktools/filters/abbrev-convert.rb -k tmpfile.euc | skkdic-expr2 | iconv -f=EUC-JP -t=UTF-8 > ./data/SKK-JISYO.L.hira-kata"
  sh "/bin/rm -f tmpfile.euc"
end
