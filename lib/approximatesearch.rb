
require 'kyotocabinet'
require 'amatch'
include KyotoCabinet

class ApproximateSearch
  def initialize( jarow_shikii )
    @jarow_shikii = jarow_shikii
  end

  def search( db, keyword, okuri_ari )
    readymade_key = if okuri_ari
                      keyword.slice( 0, 2 ).upcase
                    else
                      keyword.slice( 0, 2 ).downcase
                    end
    readymade_key = "(" + readymade_key ")"
    
    str = db.get( readymade_key )
    printf( "%s : %s", readymade_key, str )
  end
end
