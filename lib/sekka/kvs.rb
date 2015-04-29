# kvs.rb  -  "wrapper library for Key-Value-Store"
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
require 'memcache'

class Kvs
  def initialize( dbtype )
    @tcFlag = true
    begin
      require 'tokyocabinet'
    rescue LoadError
      @tcFlag = false
    end

    @redisFlag = true
    begin
      require 'redis'
    rescue LoadError
      @redisFlag = false
    end

    @gdbmFlag = true
    begin
      require 'gdbm'
    rescue LoadError
      @gdbmFlag = false
    end

    @daybreakFlag = true
    begin
      require 'daybreak'
    rescue LoadError
      @daybreakFlag = false
    end

    @dbtype = dbtype
    case dbtype
    when :tokyocabinet
      if @tcFlag
        @db = TokyoCabinet::HDB.new( )
      else
        raise RuntimeError, "Kvs.new() missed require( 'tokyocabinet' )."
      end

    when :redis
      if not @redisFlag
        raise RuntimeError, "Kvs.new() missed require( 'redis' )."
      end

    when :memcache
      # do nothing

    when :gdbm
      if @gdbmFlag
        # do nothing
      else
        raise RuntimeError, "Kvs.new() missed require( 'gdbm' )."
      end

    when :daybreak
      if @daybreakFlag
        # do nothing
      else
        raise RuntimeError, "Kvs.new() missed require( 'daybreak' )."
      end

    when :pure
      # do nothing
    else
      raise ArgumentError, "Kvs.new() requires reserved DB typename"
    end
  end

  def open( name )
    case @dbtype
    when :tokyocabinet
      if not @db.open( name, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT )
        raise RuntimeError, sprintf( "TokyoCabinet::HDB.open error: file=%s", name )
      end
    when :redis
      @db = Redis.new( :host => name )
    when :memcache
      @db = MemCache.new( name,
                          :connect_timeout => 1000.0,
                          :timeout => 1000.0 )
    when :gdbm
      if not name.match( /.db$/ )
        name = name + ".db"
      end
      @db = GDBM.new( name, nil, GDBM::FAST | GDBM::WRCREAT )
    when :daybreak
      if not name.match( /.daybreak$/ )
        name = name + ".daybreak"
      end
      @db = Daybreak::DB.new name
    when :pure
      @name = name
      if File.exist?( @name )
        File.open( @name ) {|f|
          @db = eval( f.read() )
        }
        @db
      else
        @db = Hash.new
      end
    else
      raise RuntimeError
    end
  end

  def fixdb( )
    case @dbtype
    when :tokyocabinet
      if not @db.optimize( )
        raise RuntimeError, sprintf( "TokyoCabinet::HDB.optimize error: file=%s", name )
      end
    when :daybreak
      @db.compact
    end
    true
  end

  def put!( key, value, timeout = 0 )
    if not self.pure_put!( key, value, timeout )
      raise RuntimeError sprintf( "put! error: key=%s", key.force_encoding("ASCII-8BIT"))
    end
    value
  end

  def pure_put!( key, value, timeout = 0 )
    if 0 < key.size
      case @dbtype
      when :tokyocabinet, :gdbm, :redis
        @db[ key.force_encoding("ASCII-8BIT") ] = value.force_encoding("ASCII-8BIT")
      when :memcache
        @db.set( key.force_encoding("ASCII-8BIT"), value.force_encoding("ASCII-8BIT"), timeout )
      when :daybreak
        @db.set!( key.force_encoding("ASCII-8BIT"), value.force_encoding("ASCII-8BIT"))
      when :pure
        @db[ key ] = value
      else
        raise RuntimeError
      end
    end
    value
  end

  def get( key, fallback = false )
    if 0 == key.size
      fallback
    else
      val = @db[ key ]
      if val
        val.force_encoding("UTF-8")
      else
        fallback
      end
    end
  end

  def delete( key )
    case @dbtype
    when :redis
      @db.del( key )
    when :daybreak
      @db.delete!( key )
    else
      @db.delete( key )
    end
    true
  end

  def clear()
    case @dbtype
    when :tokyocabinet, :gdbm, :daybreak, :pure
      @db.clear
    when :redis
      @db.flushall
    when :memcache
      # do nothing
    else
      raise RuntimeError
    end
  end

  # return array of key string
  def keys()
    case @dbtype
    when :tokyocabinet, :gdbm, :redis
      @db.keys.map { |k|
        k.force_encoding("UTF-8")
      }
    when :memcache
      raise RuntimeError, "Kvs#keys method was not implemented for memcache."
    when :daybreak, :pure
      @db.keys
    else
      raise RuntimeError
    end
  end

  def forward_match_keys( prefix )
    case @dbtype
    when :tokyocabinet
      @db.fwmkeys( prefix ).each { |k|
        k.force_encoding("UTF-8")
      }
    when :redis
      @db.keys( prefix + "*" ).each { |k|
        k.force_encoding("UTF-8")
      }
    when :memcache
      raise RuntimeError, "Kvs#forward_match_keys method was not implemented for memcache."
    when :gdbm, :daybreak, :pure
      self.keys( ).select {|key|
        key.match( "^" + prefix )
      }
    else
      raise RuntimeError
    end
  end

  def close()
    case @dbtype
    when :tokyocabinet, :daybreak, :gdbm
      @db.close
    when :memcache, :redis
      # do nothing
    when :pure
      File.open( @name, "w" ) { |f|
        f.print( @db )
      }
    else
      raise RuntimeError
    end
  end

  ## for testing
  def _db()
    @db
  end
end
