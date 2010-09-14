require 'kyotocabinet'
require 'memcache'


class Kvs
  def initialize( dbtype )
    @dbtype = dbtype
    case dbtype
    when :kyotocabinet
      @db = KyotoCabinet::DB.new( )
    when :memcache
      # do nothing
    else
      raise ArgumentError, "Kvs.new() requires reserved DB typename"
    end
  end

  def open( name )
    case @dbtype
    when :kyotocabinet
      if @db.open( name )
        @db.tune_encoding "utf-8"
      else
        raise RuntimeError, sprintf( "KyotoCabinet::DB.open error: file=%s", name )
      end
    when :memcache
      p "kiyoka!"
      @db = MemCache.new( name )
    else
      raise RuntimeError
    end
  end

  def put!( key, value )
    #p "put! " + key + ":" + value
    @db.set( key.force_encoding("ASCII-8BIT"), value.force_encoding("ASCII-8BIT"))
  end

  def get( key, fallback = false )
    val = @db.get( key )
    if val
      val.force_encoding("UTF-8")
    else
      fallback
    end
  end

  def clear()
    case @dbtype
    when :kyotocabinet
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
    when :kyotocabinet
      arr = []
      @db.each { |key,value|
        arr << key
      }
      arr
    when :memcache 
      raise RuntimeError, "Kvs#keys method was not implemented for memcache."
    else
      raise RuntimeError
    end
  end

  def close()
    case @dbtype
    when :kyotocabinet
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

