
require 'kyotocabinet'
include KyotoCabinet

class KeyList
  def getKeyList( filename, keyword )
    arr   = []
    KyotoCabinet::DB.process( filename ) { |db|
      k0    = keyword.slice( 0, 2 )
      kk0   = k0
      cur   = db.cursor
      cur.jump k0
      while k0 == kk0
        kk = cur.get_key
        kk0 = kk.slice( 0, 2 )
        arr << kk
        cur.step
      end
    }
    return arr.to_list
  end
end

