# approximatesearch.rb  -  "approximate search library"
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
require 'fuzzystringmatch'
require 'sekka/kvs'

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

  def search( userid, kvs, keyword, type )
    readymade_key = case type
                    when 'k' # okuri nashi kanji entry
                      "(" + keyword.slice( 0, 2 ).downcase + ")"
                    when 'K' # okuri ari   kanji entry
                      "(" + keyword.slice( 0, 2 ).upcase   + ")"
                    when 'h' # hiragana phrase entry
                      "{" + keyword.slice( 1, 2 ).downcase + "}"
                    else
                      raise sprintf( "Error: ApproximateSearch#search unknown type %s ", type )
                    end

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
