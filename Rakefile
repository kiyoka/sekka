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
