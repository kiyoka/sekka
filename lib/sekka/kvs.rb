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
require 'tokyocabinet'
require 'memcache'


class Kvs
  def initialize( dbtype )
    @dbtype = dbtype
    case dbtype
    when :tokyocabinet
      @db = TokyoCabinet::HDB.new( )
      # @db.setxmsiz(512 * 1024 * 1024)  # expand memory
    when :memcache
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
    when :memcache
      @db = MemCache.new( name )
    else
      raise RuntimeError
    end
  end

  def fixdb( )
    if not @db.optimize( )
      raise RuntimeError, sprintf( "TokyoCabinet::HDB.optimize error: file=%s", name )
    end
    true
  end

  def put!( key, value, timeout = 0 )
    if 0 < key.size
      #p "put! " + key + ":" + value
      case @dbtype
      when :tokyocabinet
        if not @db[ key.force_encoding("ASCII-8BIT") ] = value.force_encoding("ASCII-8BIT")
          raise RuntimeError sprintf( "TokyoCabinet::HDB.put error: key=%s", key.force_encoding("ASCII-8BIT"))
        end
      when :memcache
        @db.set( key.force_encoding("ASCII-8BIT"), value.force_encoding("ASCII-8BIT"), timeout )
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
      val = @db.get( key )
      if val
        val.force_encoding("UTF-8")
      else
        fallback
      end
    end
  end

  def delete( key )
    @db.delete( key )
  end

  def clear()
    case @dbtype
    when :tokyocabinet
      @db.clear
    when :memcache
      # do nothing
    else
      raise RuntimeError
    end
  end

  # return array of key string
  def keys()
    case @dbtype
    when :tokyocabinet
      @db.keys.map { |k|
        k.force_encoding("UTF-8")
      }
    when :memcache
      raise RuntimeError, "Kvs#keys method was not implemented for memcache."
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
    when :memcache
      raise RuntimeError, "Kvs#forward_match_keys method was not implemented for memcache."
    else
      raise RuntimeError
    end
  end

  def close()
    case @dbtype
    when :tokyocabinet
      @db.close
    when :memcache
      # do nothign
    else
      raise RuntimeError
    end
  end

  ## for testing
  def _db()
    @db
  end
end
