
require 'kyotocabinet'
include KyotoCabinet

class SekkaRubyUtil
  def get_search_keyword_list( db, keyword, regex )
    arr   = []
    
    k0    = keyword.slice( 0, 2 )
    kk0   = k0
    cur   = db.cursor
    cur.jump k0
    while k0 == kk0
      kk = cur.get_key
      kk0 = kk.slice( 0, 2 )
      #printf( "kk = [%s] : k0 = [%s] kk0 = [%s] \n", kk, k0, kk0 )
      if regex.match( kk )
        arr << kk
      end
      cur.step
    end
    return arr.to_list
  end
end
