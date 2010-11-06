#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rack'
require 'nendo'
require 'eventmachine'
require 'syslog'

class SekkaServer
  def initialize( dictSource, cacheSource = false)
    @core = Nendo::Core.new()
    @core.loadInitFile
    @core.evalStr( "(use debug.syslog)" )
    @core.load( "./lib/henkan.nnd" )
    @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
    @core.evalStr( '(export-to-ruby writeToString)' )
    (@kvs,@cachesv) = @core.openSekkaJisyo( dictSource, cacheSource )
    @queue = EM::Queue.new

    begin
      @thread = Thread.new do
        Thread.pass
        EventMachine::run {
          EventMachine::PeriodicTimer.new( 5 ) do
            while not @queue.empty?
              @queue.pop { |word| 
                arr = word.split( /[ ]+/ )
                userid   = arr[0]
                dictline = arr[1] + " " + arr[2]
                registered = @core.registerUserJisyo(userid, @kvs, dictline)
                if registered
                  puts "Info: added to dict           userid[" + userid + "] dictline[" + dictline + "]"
                else
                  puts "Info: ignored (already added) userid[" + userid + "] dictline[" + dictline + "]"
                end
              }
            end
          end
        }
      end
      @thread.run
    rescue
      p $!  # => "unhandled exception"
    end
  end

  def call(env)
    req = Rack::Request.new(env)
    body = case req.request_method
           when 'POST'
             case req.path
             when "/henkan"
               arg = req.params['arg'].force_encoding("UTF-8")
               arr = arg.split( /[ ]+/ )
               @core.writeToString( @core.sekkaHenkan( req.params['userid'], @kvs, @cachesv, arr[0], arr[1].to_i, "normal"))
             when "/kakutei"
               arg = req.params['arg'].force_encoding("UTF-8")
               arr = arg.split( /[ ]+/ )
               @core.sekkaKakutei( req.params['userid'], @kvs, @cachesv, arr[0], arr[1] )
             when "/register"
               dict = req.params['arg'].force_encoding( "UTF-8" ).split( "\n" )
               dict.each { |x| @queue.push( req.params['userid'] + " " + x ) }
               sprintf( "register request successful (%s) words", dict.size )
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

