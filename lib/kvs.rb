require 'tokyocabinet'
require 'memcache'


class Kvs
  def initialize( dbtype )
    @dbtype = dbtype
    case dbtype
    when :tokyocabinet
      @db = TokyoCabinet::HDB.new( )
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

  def put!( key, value, timeout = 0 )
    if 0 < key.size
      #p "put! " + key + ":" + value
      case @dbtype
      when :tokyocabinet
        @db[ key.force_encoding("ASCII-8BIT") ] = value.force_encoding("ASCII-8BIT")
      when :memcache
        @db.set( key.force_encoding("ASCII-8BIT"), value.force_encoding("ASCII-8BIT"), timeout )
      else
        raise RuntimeError
      end
    end
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

