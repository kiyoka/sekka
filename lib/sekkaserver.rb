#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
#
# sekkaserver.rb  -  "a sekka server"
#
#   Copyright (c) 2015  Kiyoka Nishiyama  <kiyoka@sumibi.org>
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
require 'uri'
require 'date'
require 'sekkaconfig'
require 'sekka/sekkaversion'
require 'memcache'

module SekkaServer
  class Server
    def initialize
      $LOAD_PATH.push( File.dirname(__FILE__) + "/../lib" )
      @core = Nendo::Core.new()
      @core.loadInitFile
      @core.disableRuntimeCheck( )
      begin
        require 'syslog'
        @core.evalStr( "(use debug.syslog)" )
      rescue LoadError
        STDERR.printf( "Sekka Warning: this platform does not support 'syslog'...\n" )
        @core.evalStr( "(use debug.null)" )
      end
      @core.evalStr( "(use sekka.henkan)" )
      @core.evalStr( '(define (writeToString sexp) (write-to-string sexp))' )
      @core.evalStr( '(export-to-ruby writeToString)' )
      @core.evalStr( "(use rfc.json)" )
      @core.evalStr( '(define (constructJsonString sexp) (construct-json-string sexp))' )
      @core.evalStr( '(export-to-ruby constructJsonString)' )
      (@kvs,@initialCachesv) = @core.openSekkaJisyo( SekkaServer::Config.dictType,
                                                      SekkaServer::Config.dictSource,
                                                      SekkaServer::Config.cacheSource )

      # connection check to memcached
      fail_message = "sekka-server: failt to access memcached.\n"
      begin
        @core.flushCacheServer(@initialCachesv)
      rescue MemCache::MemCacheError
        STDERR.printf(fail_message)
        exit(1)
      rescue Timeout
        STDERR.printf(fail_message)
        exit(1)
      rescue SocketError
        STDERR.printf(fail_message)
        exit(1)
      rescue Errno::ECONNREFUSED
        STDERR.printf(fail_message)
        exit(1)
      end
      
      @cachesv = @initialCachesv
      @downTime = DateTime.now
      
      version = @kvs.get( "SEKKA:VERSION" )
      if not SekkaVersion.dictVersion == version
        STDERR.printf(   "Sekka Error: require dict version [%s] but got [%s].\n", SekkaVersion.dictVersion, version )
        exit( 1 )
      end

      @queue = EM::Queue.new
      @mutex = Mutex.new

      STDERR.puts(   "----- Sekka Server Started -----" )
      STDERR.printf( "  Sekka version  : %s\n", SekkaVersion.version            )
      STDERR.printf( "  Nendo version  : %s\n", Nendo::Core.version             )
      STDERR.printf( "  dict  version  : %s\n", SekkaVersion.dictVersion        )
      STDERR.printf( "  dict-type      : %s\n", SekkaServer::Config.dictType    )
      STDERR.printf( "  dict-db        : %s\n", SekkaServer::Config.dictSource  )
      STDERR.printf( "  memcached      : %s\n", SekkaServer::Config.cacheSource )
      STDERR.printf( "  listenPort     : %s\n", SekkaServer::Config.listenPort  )
      STDERR.printf( "  proxyHost      : %s\n", SekkaServer::Config.proxyHost   )
      STDERR.printf( "  proxyPort      : %s\n", SekkaServer::Config.proxyPort   )
      STDERR.printf( "  maxQueryLength : %s\n", SekkaServer::Config.maxQueryLength )
      STDERR.puts(   "--------------------------------" )

      begin
        @thread = Thread.new do
          Thread.pass
          EventMachine::run {
            d = DateTime.now
            EventMachine::PeriodicTimer.new( 1 ) do
              if not @queue.empty?
                @queue.pop { |word|
                  arr = word.split( /[ ]+/ )
                  command   = arr[0]
                  userid    = arr[1]
                  @mutex.synchronize {
                    case command
                    when 'r' # register
                      dictline =
                        if 4 == arr.size
                          arr[2] + " " + arr[3]
                        else
                          ";; comment"
                        end
                      STDERR.puts "Info: processing  [register(" + dictline + ") on " + userid + "] batch command... "
                      begin
                        registered = @core.registerUserJisyo(userid, @kvs, dictline)
                      rescue RuntimeError
                        STDERR.puts "Info: missing [register(" + dictline + ")] batch command..."
                      end
                      if registered
                        str = d.strftime( "%D %X" )
                        STDERR.puts "ADDED " + str
                        @core.flushCacheServer( @cachesv )
                      else
                        STDERR.puts "ignored"
                      end
                    when 'k' # kakutei
                      arr = word.split( /[ ]+/ )
                      _key   = arr[2]
                      _tango = arr[3]
                      STDERR.puts "Info: processing  [kakutei(" + _tango + ")] batch command..."
                      begin
                        @core.sekkaKakutei( userid, @kvs, @cachesv, _key, _tango )
                      rescue RuntimeError
                        STDERR.puts "Info: missing [kakutei(" + _tango + ")] batch command..."
                      end

                      STDERR.printf( "Info: kakutei [%s:%s] \n", _key, _tango )
                    when 'f' # flush
                      STDERR.puts "Info: processing [flush] batch command..."
                      begin
                        n = @core.flushUserJisyo( userid, @kvs )
                      rescue RuntimeError
                        STDERR.puts "Info: missing [flush] batch command..."
                      end
                      @core.flushCacheServer( @cachesv )
                      STDERR.printf( "info : flush [%s] user's dict %d entries. \n", userid, n )
                    end
                  }
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
             when 'GET'
               getMethod(req)
             when 'POST'
               if !req.params.has_key?('userid')
                 str = "Err: parameter 'userid' required"
                 STDERR.puts str
                 @core.writeToString( str )
               elsif !req.params.has_key?('format')
                 str = "Err: parameter 'format' required"
                 STDERR.puts str
                 @core.writeToString( str )
               else
                 postMethod(req)
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
    
    def getMethod(req)
      case req.path
      when "/status"
        "OK\n"
      end
    end
    
    def isJson(format)
      return "json" == format.downcase
    end
    
    def postMethod(req)
      revertMemcache()
                 
      userid = URI.decode( req.params['userid'].force_encoding("UTF-8") )
      format = URI.decode( req.params['format'].force_encoding("UTF-8") )
      case req.path
      when "/henkan"
        _yomi    = URI.decode( req.params[  'yomi'].force_encoding("UTF-8") )
        _limit   = URI.decode( req.params[ 'limit'].force_encoding("UTF-8") )
        _method  = URI.decode( req.params['method'].force_encoding("UTF-8") )
        _orRedis = if :redis == SekkaServer::Config.dictType then "or Redis-server" else "" end
        @mutex.synchronize {
          begin
            if SekkaServer::Config.maxQueryLength < _yomi.size
              result = sprintf( "sekka-server: query string is too long (over %d character length)", SekkaServer::Config.maxQueryLength )
            else
              if isJson(format)
                obj = @core.sekkaHenkan( userid, @kvs, @cachesv, _yomi, _limit.to_i, _method, false )
                @core.constructJsonString(obj)
              else
                obj = @core.sekkaHenkan( userid, @kvs, @cachesv, _yomi, _limit.to_i, _method, true )
                @core.writeToString(obj)
              end
            end
          rescue MemCache::MemCacheError
            result = "sekka-server: memcached server is down (or may be offline)"
            disableMemcache()
          rescue Timeout
            result = "sekka-server: Timeout to request memcached server #{_orRedis} (or may be offline)"
            disableMemcache()
          rescue SocketError
            result = "sekka-server: SocketError to request memcached server #{_orRedis} (or may be offline)"
            disableMemcache()
          rescue Errno::ECONNREFUSED
            result = "sekka-server: ConnectionRefused to request memcached server #{_orRedis} (or may be offline)"
            disableMemcache()
          end
        }
      when "/kakutei"
        _key    = URI.decode( req.params[   'key'].force_encoding("UTF-8") )
        _tango  = URI.decode( req.params[ 'tango'].force_encoding("UTF-8") )
        @queue.push( 'k ' + userid + " " + _key + " " + _tango )
      when "/register"
        dict    = URI.decode( req.params['dict'].force_encoding( "UTF-8" ) ).split( "\n" )
        dict.each { |x|
          @queue.push( 'r ' + userid + " " + x )
        }
        sprintf( "sekka-server:register request (%s) words added, current-queue-size (%s)", dict.size, @queue.size )
      when "/flush"
        @queue.push( 'f ' + userid )
        sprintf( "sekka-server:flush request successful." )
      when "/googleime"
        _yomi   = URI.decode( req.params[  'yomi'].force_encoding("UTF-8") )
        printf( "info : google-ime request [%s]\n", _yomi )
        result = "sekka-server: google-ime error"
        begin
          result = @core.googleIme( _yomi,
                                    SekkaServer::Config.proxyHost,
                                    SekkaServer::Config.proxyPort )
        rescue Timeout
          result = "sekka-server: Timeout to request google-ime (may be offline)"
        rescue SocketError
          result = "sekka-server: SocketError to request google-ime (may be offline)"
        rescue Errno::ECONNREFUSED
          result = "sekka-server: ConnectionRefused to request google-ime (or may be offline)"
        end
        @core.writeToString( result )
      else
        sprintf( "sekka-server:unknown path name. [%s]", req.path )
      end
    end

    def revertMemcache()
      now = DateTime.now
      ## STDERR.printf( "Sekka Debug: [%d]/[%d]\n", @downTime.to_time.to_i, now.to_time.to_i )
      if not @cachesv
        if (@downTime.to_time.to_i + (10 * 60)) < now.to_time.to_i
          @cachesv = @initialCachesv
          STDERR.printf( "Sekka Info: revert using memcache server. [%s]\n", @downTime )        
        end
      end
    end
    
    def disableMemcache()
      @cachesv  = false
      @downTime = DateTime.now
      STDERR.printf( "Sekka Warning: disabled using memcache server. [%s]\n", @downTime )
    end
  end
end
