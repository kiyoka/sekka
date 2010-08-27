#-*- mode: ruby; -*-
#  Rakefile for Sekka
#
#
require 'rake'

task :check do
  sh "/bin/rm -f test.record"
  sh "/bin/rm -f test.kct"
  sh "echo > test.log"
  [ "./test/roman-lib.nnd", 
    "./test/jisyo.nnd", 
    "./test/henkan-main.nnd"
  ].each {|filename|
    sh  sprintf( "ruby -I ./lib /usr/local/bin/nendo %s", filename )
  }
  sh "cat test.record" 
end

task :jisyo do
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.S.201001    >  ./data/SEKKA-JISYO.S.201001"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.hira-kata >> ./data/SEKKA-JISYO.S.201001"
#  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.201008 > ./data/SEKKA-JISYO.L.201008"
end

task :load do
  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.S.201001"
#  sh "time ./bin/sekka-jisyo load    ./data/SEKKA-JISYO.L.201008"
end

task :demo do
#  sh "./bin/sekka-engine ./data/SEKKA-JISYO.S.201001"
  sh "./bin/sekka-engine ./data/SEKKA-JISYO.L.201008"
end

task :rackup do
  sh "rackup ./lib/sekka.ru"
end

task :katakanago do
  sh "nkf --euc ./data/SKK-JISYO.L.201008 > tmpfile.euc"
  sh "/usr/share/skktools/filters/abbrev-convert.rb -k tmpfile.euc | skkdic-expr2 | iconv -f=EUC-JP -t=UTF-8 > ./data/SKK-JISYO.L.hira-kata"
  sh "/bin/rm -f tmpfile.euc"
end
