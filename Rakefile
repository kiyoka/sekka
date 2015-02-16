# -*- coding: utf-8 -*-
# -*- mode: ruby; -*-
#                                                  Rakefile for Sekka
#
# Release Engineering:
#   1. edit the VERSION.yml file
#   2. rake compile  &&   rake test   &&   rake build
#      to generate pkg/sekka-x.x.x.gem
#   3. install sekka-x.x.x.gem to clean environment and test
#   4. rake release
#   5. gem push pkg/sekka-x.x.x.gem   ( need gem version 1.3.6 or higer. Please "gem update --system" to update )
#
# Enviroment Variables:
#   Please select from
#     DB=gdbm
#     DB=tokyocabinet
#     DB=redis
#     DB=                (default)
#     DB=all             gdbm/tokyocabinet/redis
#

require 'rake'
require "bundler/gem_tasks"
require 'jeweler2'

task :default => [:test] do
end

task :compile do
  # generate version.rb
  dictVersion = "1.5.0"
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
          if line.match( /Version:/ )
            sprintf( ';; Version: %s          ;;SEKKA-VERSION', vh.to_s ) + "\n"
          else
            sprintf( '  "%s" ;;SEKKA-VERSION', vh.to_s ) + "\n"
          end
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
  sh "ruby -I ./lib ./bin/sekka-path > ./path1.tmp"
  path1 = open( "./path1.tmp" ) {|f|
    f.readline.chomp
  }
  path2 = File.dirname( __FILE__ )
  unless path1 == path2
    puts STDERR.printf( "Error: on <sekka-path> requires [%s] but got [%s].", path2, path1 )
    exit 1
  end

  ["test.record", "test.tch", "test.db" ].each {|name|
    File.unlink( name ) if File.exist?( name )
  }
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
  when 'gdbm'
    files << "./test/henkan-main.nnd  gdbm"
  when 'tokyocabinet'
    files << "./test/henkan-main.nnd  tokyocabinet"
  when 'redis'
    files << "./test/redis.nnd"
    files << "./test/henkan-main.nnd  redis"
  when 'pure'
    files << "./test/henkan-main.nnd  pure"
  when 'all'
    files << "./test/henkan-main.nnd  gdbm"
    files << "./test/henkan-main.nnd  tokyocabinet"
    files << "./test/henkan-main.nnd  redis"
    files << "./test/henkan-main.nnd  pure"
  else # default
    files << "./test/henkan-main.nnd  tokyocabinet"
    files << "./test/henkan-main.nnd  pure"
  end
  files.each {|filename|
    sh  sprintf( "ruby -I ./lib -S nendo -d %s", filename )
  }
  sh "cat test.record"
end

task :bench do
  sh "time ruby -I ./lib /usr/local/bin/nendo ./test/approximate-bench.nnd"
  sh "time ruby -I ./lib /usr/local/bin/nendo ./test/henkan-bench.nnd"
end

task :alljisyo  => [ :alljisyoS, :alljisyoL, :alljisyoH ]
task :alljisyoS => [ :jisyoS, :loadS, :ngramS, :dumpS, :md5 ]
task :alljisyoL => [ :jisyoL, :loadL, :ngramL, :dumpL, :md5 ]

task :md5 do
  sh "md5sum ./data/SEKKA-JISYO.SMALL.N.tsv > ./data/SEKKA-JISYO.SMALL.N.md5"
  sh "md5sum ./data/SEKKA-JISYO.LARGE.N.tsv > ./data/SEKKA-JISYO.LARGE.N.md5"
end

task :jisyoS do
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.L.201501           >  ./data/SEKKA-JISYO.SMALL.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.SMALL.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase    >> ./data/SEKKA-JISYO.SMALL.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase2   >> ./data/SEKKA-JISYO.SMALL.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase3   >> ./data/SEKKA-JISYO.SMALL.N"
end

task :jisyoL do
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.L.201501           >  ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.L.hira-kata        >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.fullname           >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.jinmei             >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.station            >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase    >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase2   >> ./data/SEKKA-JISYO.LARGE.N"
  sh "ruby ./bin/sekka-jisyo convertN ./data/SKK-JISYO.hiragana-phrase3   >> ./data/SEKKA-JISYO.LARGE.N"
end

task :loadS do
  sh "ruby ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.SMALL.N  ./data/SEKKA-JISYO.SMALL.N.tch#xmsiz=1024m"
end

task :loadL do
  sh "ruby ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.LARGE.N  ./data/SEKKA-JISYO.LARGE.N.tch#xmsiz=1024m"
end

task :dumpS do
  sh "ruby ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.SMALL.N.tch#xmsiz=1024m >  ./data/SEKKA-JISYO.SMALL.N.tsv"
  sh "cat ./data/SEKKA-JISYO.SMALL.2GRAM.tsv                                    >> ./data/SEKKA-JISYO.SMALL.N.tsv"
  sh "cat ./data/SEKKA-JISYO.SMALL.SKIP2GRAM.tsv                                >> ./data/SEKKA-JISYO.SMALL.N.tsv"
end

task :dumpL do
  sh "ruby ./bin/sekka-jisyo dump    ./data/SEKKA-JISYO.LARGE.N.tch#xmsiz=1024m >  ./data/SEKKA-JISYO.LARGE.N.tsv"
  sh "cat ./data/SEKKA-JISYO.LARGE.2GRAM.tsv                                    >> ./data/SEKKA-JISYO.LARGE.N.tsv"
  sh "cat ./data/SEKKA-JISYO.LARGE.SKIP2GRAM.tsv                                >> ./data/SEKKA-JISYO.LARGE.N.tsv"
end

task :ngramS do
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/ngram_to_sekkatsv.nnd      2  < ./data/ngram/nwc2010.1000/2gm.1000.txt > ./data/SEKKA-JISYO.SMALL.2GRAM.tsv"
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/ngram_to_sekkatsv.nnd  skip2  < ./data/ngram/nwc2010.1000/3gm.1000.txt > ./data/SEKKA-JISYO.SMALL.SKIP2GRAM.tsv"
end

task :ngramL do
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/ngram_to_sekkatsv.nnd      2  < ./data/ngram/nwc2010.100/2gm.100.txt   > ./data/SEKKA-JISYO.LARGE.2GRAM.tsv"
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/ngram_to_sekkatsv.nnd  skip2  < ./data/ngram/nwc2010.100/3gm.100.txt   > ./data/SEKKA-JISYO.LARGE.SKIP2GRAM.tsv"
end


# SKK-JISYO.hiragana-phrase はWikipediaから作られる。
task :phrase => [ "/tmp/jawiki.txt.gz", "./data/wikipedia/jawiki.hiragana.txt" ] do
  sh "sort ./data/wikipedia/jawiki.hiragana.txt | uniq -c | sort > ./data/wikipedia/ranking.txt"
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase_in_wikipedia2.nnd ./data/wikipedia/ranking.txt > ./data/SKK-JISYO.hiragana-phrase"
  sh "echo 'して //' >> ./data/SKK-JISYO.hiragana-phrase"
end

file "./data/wikipedia/jawiki.hiragana.txt" do
  sh "zcat /tmp/jawiki.txt.gz | mecab --input-buffer-size=65536 -O wakati --output=/tmp/jawiki.wakati.txt"
  sh "ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase_in_wikipedia.nnd /tmp/jawiki.wakati.txt > ./data/wikipedia/jawiki.hiragana.txt"
  sh "rm -f /tmp/jawiki.wakati.txt"
end

file "/tmp/jawiki.txt.gz" do
  sh "mkdir -p ./data/wikipedia/txt"
  sh "wget http://dumps.wikimedia.org/jawiki/latest/jawiki-latest-pages-articles.xml.bz2 -O /tmp/jawiki-latest-pages-articles.xml.bz2"
  sh "wp2txt --input-file /tmp/jawiki-latest-pages-articles.xml.bz2 --output-dir ./data/wikipedia/txt"
  sh "cat ./data/wikipedia/txt/*.txt | gzip -c > /tmp/jawiki.txt.gz"
  sh "rm -f ./data/wikipedia/txt/*.txt"
  sh "rm -f /tmp/jawiki-latest-pages-articles.xml.bz2"
end


# SKK-JISYO.hiragana-phrase2 はIPADicから作られる。
task :phrase2 => [ "./data/ipadic.all.utf8.txt" ] do
  sh "time ruby -I ./lib /usr/local/bin/nendo ./data/hiragana_phrase_in_ipadic.nnd             ./data/ipadic.all.utf8.txt | sort | uniq > ./data/SKK-JISYO.hiragana-phrase2"
end

file "./data/ipadic.all.utf8.txt" do
  sh "wget http://chasen.aist-nara.ac.jp/stable/ipadic/ipadic-2.7.0.tar.gz -O /tmp/ipadic-2.7.0.tar.gz"
  sh "tar zxfC /tmp/ipadic-2.7.0.tar.gz /tmp"
  sh "iconv -f euc-jp -t utf-8 /tmp/ipadic-2.7.0/*.dic > ./data/ipadic.all.utf8.txt"
end

# SKK-JISYO.hiragana-phrase3 kiyokaが普段の運用で不足していると思ったものを手で補ったもの。
# SKK-JISYO.hiragana-phrase3 はgitにコミットする必要あり。
#

task :rackup do
  # how to install mongrel is "gem install mongrel --pre"
  sh "ruby -I ./lib ./bin/sekka-server"
end

# SKK-JISYO.L.hira-kata はSKK辞書のカタカナ語を抜き出したもの。
task :katakanago do
  sh "nkf --euc ./data/SKK-JISYO.L.201501 > tmpfile.euc"
  sh "/usr/share/skktools/filters/abbrev-convert.rb -k tmpfile.euc | skkdic-expr2 | /usr/bin/iconv -f EUC-JP -t UTF-8 > ./data/SKK-JISYO.L.hira-kata"
  sh "cat ./data/MY-JISYO.hira-kata >> ./data/SKK-JISYO.L.hira-kata"
  sh "/bin/rm -f tmpfile.euc"
end
