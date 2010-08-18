#-*- mode: ruby; -*-
#  Rakefile for Sekka
#
#
require 'rake'

task :check do
  sh "/bin/rm -f test.record"
  sh "echo > test.log"
  [ "./test/jisyo.nnd"
  ].each {|filename|
    sh  sprintf( "ruby -I ./lib /usr/local/bin/nendo %s", filename )
  }
  sh "cat test.record" 
end

task :jisyo do
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.S.201001 > ./data/SEKKA-JISYO.S.201001"
  sh "time ./bin/sekka-jisyo convert ./data/SKK-JISYO.L.201008 > ./data/SEKKA-JISYO.L.201008"
end
