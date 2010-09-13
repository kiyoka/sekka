require 'kyotocabinet'
require 'memcache'


class Kvs
  def initialize( dbtype )
    case dbtype
    when :kyotocabinet
      @dbtype = dbtype
      @db = KyotoCabinet::DB.new( )
    when :memcache
      raise ArgumentError
    else
      raise ArgumentError, "Kvs.new() requires reserved DB typename"
    end
  end

  def open( name )
    case @dbtype
    when :kyotocabinet
      if @db.open( name + ".kct" )
        @db.tune_encoding "utf-8"
      else
        raise RuntimeError, sprintf( "KyotoCabinet::DB.open error: file=%s", name + ".kct" )
      end
    when :memcache
      raise RuntimeError
    end
  end

  def put!( key, value )
    # p "put! " + key + ":" + value
    @db.store( key, value )
  end

  def get( key, fallback = false )
    val = @db.get( key )
    if val
      val
    else
      fallback
    end
  end

  def clear()
    case @dbtype
    when :kyotocabinet
      @db.clear
    when :memcache 
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
      raise RuntimeError, "Kvs#keys not implemented for memcache."
    end
  end

  def close()
    case @dbtype
    when :kyotocabinet, :memcache
      @db.close
    end
  end
end

