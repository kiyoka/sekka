$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../app/"))
 
Dir.glob(File.expand_path('vendor/bundle/jruby/*/gems/*/lib')).each{|path|
  $LOAD_PATH << path if !$LOAD_PATH.include?(path)
}
 
require 'app/sekka-server'
 
main
