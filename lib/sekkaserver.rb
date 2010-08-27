#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rack'
require 'nendo'

class SekkaServer
  def initialize
    @core = Nendo::Core.new()
    @core.loadInitFile
    @core.evalStr( "(use debug.syslog)" )
    @core.load( "./lib/henkan.nnd" )
    @core.load( "./lib/jisyo-db.nnd" )
    @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
    @core.evalStr( '(export-to-ruby writeToString)' )
    @db = @core.openSekkaJisyo( "./data/SEKKA-JISYO.L.201008" )
#    @db = @core.openSekkaJisyo( "./data/SEKKA-JISYO.S.201001" )
  end

  def call(env)
    req = Rack::Request.new(env)
    body = case req.request_method
           when 'POST'
             case req.path
             when "/henkan"
               @core.writeToString( @core.sekkaHenkan( @db, req.params['arg'] ))
             when "/kakutei"
               arg = req.params['arg'].force_encoding("UTF-8")
               arr = arg.split( /[ ]+/ )
               @core.sekkaKakutei( @db, arr[0], arr[1] )
             else
               sprintf( "unknown path name. [%s]", req.path )
             end
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
