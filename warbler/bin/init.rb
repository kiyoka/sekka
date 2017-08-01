# coding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../"))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../app/"))
 
Dir.glob(File.expand_path('vendor/bundle/jruby/*/gems/*/lib')).each{|path|
  $LOAD_PATH << path if !$LOAD_PATH.include?(path)
}
 
java_import 'java.lang.System'
java_import 'javax.swing.JOptionPane'

def console_exist?
  console = System.console()
  if console.nil?
    false
  else
    true
  end
end

if console_exist?
  ENV.delete('SEKKA_DB')
  require 'app/sekka-server'
else
  require 'sekka/sekkaversion.rb'
  JOptionPane.showMessageDialog(nil, 'consoleが存在しません。 コンソールで java -jar sekka-server-' + SekkaVersion.version + '.jar を実行してください')
end
