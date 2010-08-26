#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rack'
require 'nendo'

class SekkaServer
  def initialize
    @core = Nendo::Core.new()
    @core.loadInitFile
    @core.load( "./lib/henkan.nnd" )
    @core.load( "./lib/jisyo-db.nnd" )
    @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
    @core.evalStr( '(export-to-ruby writeToString)' )
    @db = @core.openSekkaJisyo( "./data/SEKKA-JISYO.L.201008" )
  end

  def call(env)
    req = Rack::Request.new(env)
    body = case req.request_method
           when 'POST'
             @core.writeToString( @core.sekkaHenkan( @db, req.params['query'] ))
           else
             "no message."
           end
    res = Rack::Response.new { |r|
      r.status = 200
      r['Content-Type'] = "text/plain"
      r.write body
    }
    res.finish
  end
end
