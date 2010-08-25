#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rack'
require 'nendo'

class SekkaServer
  def initialize
    @core = Nendo::Core.new()
    @core.loadInitFile
    @core.evalStr( "(define (nendo_version) *nendo-version*)" )
    @core.evalStr( "(export-to-ruby nendo_version)" )
    @core.evalStr( "(define counter 0)" )
    @core.evalStr( "(define (countup) (begin (set! counter (+ counter 1)) counter))" )
    @core.evalStr( "(export-to-ruby countup)" )
  end
  def call(env)
    req = Rack::Request.new(env)
    body = case req.request_method
           when 'GET'
             if req.path == "/count"
               "counter " + @core.countup.to_s + ":" + req.path
             else
               "no message."
             end
           end
    res = Rack::Response.new { |r|
      r.status = 200
      r['Content-Type'] = "text/plain"
      r.write body
    }
    res.finish
  end
end
