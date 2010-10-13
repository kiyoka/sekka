
require 'fuzzystringmatch'
require './lib/kvs'

class ApproximateSearch
  def initialize( jarow_shikii )
    @jarow_shikii = jarow_shikii
    @jarow        = FuzzyStringMatch::JaroWinkler.new.create( :native )
  end

  def filtering( keyword, arr )
    keyword = keyword.downcase
    arr.map { |str|
      val = @jarow.getDistance( keyword, str.downcase )
      #printf( "   [%s] vs [%s] => %f\n", keyword, str.downcase, val )
      (val > @jarow_shikii) ? [ val, str ] : false
    }.select { |v| v }.sort_by {|item| 1.0 - item[0]}
  end

  def search( userid, kvs, keyword, okuri_ari )
    readymade_key = if okuri_ari
                      keyword.slice( 0, 2 ).upcase
                    else
                      keyword.slice( 0, 2 ).downcase
                    end
    readymade_key = "(" + readymade_key + ")"
    
    str = kvs.get( userid + "::" + readymade_key, false )
    if not str 
      str = kvs.get( "MASTER::" + readymade_key )
    end
    
    #printf( "#readymade_key %s : %s\n", readymade_key, str )
    if str
      filtering( keyword, str.split( /[ ]+/ ))
    else
      [ ]
    end
  end
end
