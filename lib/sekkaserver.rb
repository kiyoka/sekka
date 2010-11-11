#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
#
# sekkaserver.rb  -  "a sekka server"
#  
#   Copyright (c) 2010  Kiyoka Nishiyama  <kiyoka@sumibi.org>
#   
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#   
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#  
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#  
#   3. Neither the name of the authors nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#  
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
#  $Id: 
#
require 'rack'
require 'nendo'
require 'eventmachine'
require 'syslog'
require './lib/sekkaconfig'

module SekkaServer
  class Server
    def initialize
      $LOAD_PATH.push( File.dirname(__FILE__) + "/../lib" )
      @core = Nendo::Core.new()
      @core.loadInitFile
      @core.evalStr( "(use debug.syslog)" )
      @core.evalStr( "(use sekka.henkan)" )
      @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
      @core.evalStr( '(export-to-ruby writeToString)' )
      (@kvs,@cachesv) = @core.openSekkaJisyo( SekkaServer::Config.dictSource,
                                              SekkaServer::Config.cacheSource )
      @queue = EM::Queue.new

      STDERR.puts(   "----- Sekka Server Started -----" )
      STDERR.printf( "  dict-db  :  %s\n", SekkaServer::Config.dictSource  )
      STDERR.printf( "  memcached:  %s\n", SekkaServer::Config.cacheSource )
      STDERR.printf( "  listenPort: %s\n", SekkaServer::Config.listenPort  )
      STDERR.puts(   "--------------------------------" )

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
                 _yomi   = req.params[  'yomi'].force_encoding("UTF-8")
                 _limit  = req.params[ 'limit'].force_encoding("UTF-8")
                 _method = req.params['method'].force_encoding("UTF-8")
                 @core.writeToString( @core.sekkaHenkan( req.params['userid'], @kvs, @cachesv, _yomi, _limit.to_i, _method ))
               when "/kakutei"
                 _key    = req.params[   'key'].force_encoding("UTF-8")
                 _tango  = req.params[ 'tango'].force_encoding("UTF-8")
                 @core.sekkaKakutei( req.params['userid'], @kvs, @cachesv, _key, _tango )
               when "/register"
                 dict = req.params['dict'].force_encoding( "UTF-8" ).split( "\n" )
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
end
