#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rack'
require 'nendo'

class SekkaServer
  def initialize( dictSource, cacheSource = false)
    @core = Nendo::Core.new()
    @core.loadInitFile
    @core.evalStr( "(use debug.syslog)" )
    @core.load( "./lib/henkan.nnd" )
    @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
    @core.evalStr( '(export-to-ruby writeToString)' )
    (@kvs,@cachesv) = @core.openSekkaJisyo( dictSource, cacheSource )
  end

  def call(env)
    req = Rack::Request.new(env)
    body = case req.request_method
           when 'POST'
             case req.path
             when "/henkan"
               @core.writeToString( @core.sekkaHenkan( req.params['userid'], @kvs, @cachesv, req.params['arg'] ))
             when "/kakutei"
               arg = req.params['arg'].force_encoding("UTF-8")
               arr = arg.split( /[ ]+/ )
               @core.sekkaKakutei( req.params['userid'], @kvs, @cachesv, arr[0], arr[1] )
             when "/upload"
               result = @core.loadUserJisyo( req.params['userid'], @kvs, req.params['arg'].force_encoding( "UTF-8" ))
               if 0 < result
                 sprintf( "upload successful (%s) words", result )
               else
                 "upload failed..."
               end
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
