
require 'kyotocabinet'
require 'amatch'
include KyotoCabinet

class ApproximateSearch
  def initialize( jarow_shikii )
    @jarow_shikii = jarow_shikii
  end

  def filtering( db, keyword, arr )
    jarow = Amatch::JaroWinkler.new keyword
    arr.map { |str|
      val = jarow.match( str )
      (val > @jarow_shikii) ? [ val, str ] : false
    }.select { |v| v }.sort_by {|item| 1.0 - item[0]}
  end

  def search( db, keyword, okuri_ari )
    readymade_key = if okuri_ari
                      keyword.slice( 0, 2 ).upcase
                    else
                      keyword.slice( 0, 2 ).downcase
                    end
    readymade_key = "(" + readymade_key + ")"
    
    str = db.get( readymade_key )
    #printf( "#readymade_key %s : %s\n", readymade_key, str )
    if str
      filtering( db, keyword, str.split( /[ ]+/ ))
    else
      [ ]
    end
  end
end
