#!/usr/local/bin/ruby

require 'rack'
require 'nendo'

class SekkaServer
  def initialize
    @core = Nendo::Core.new()
  end
  def call(env)
    [200, {"Content-Type" => "text/plain"}, [ "hello, kiyoka!" ]]
  end
end
