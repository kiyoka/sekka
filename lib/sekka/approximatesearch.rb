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
require 'distributedtrie'
require 'sekka/kvs'

class ApproximateSearch
  def initialize( jarow_shikii )
    @jarow_shikii = jarow_shikii
  end

  def search( userid, kvs, keyword, type )
    arr = []
    case userid
    when "M"
      arr  = searchByUser( "M", kvs, keyword, type )
    else
      h = {}
      searchByUser( "M", kvs, keyword, type ).each { |item| h[ item[1] ] = item[0] }
      searchByUser(  userid,  kvs, keyword, type ).each { |item| h[ item[1] ] = item[0] }
      h.keys.each { |k|  arr << [ h[k], k ] }
    end
    arr.sort_by {|item| [1.0 - item[0], item[1]]}
  end

  def searchByUser( userid, kvs, keyword, type )
    pair = case type
           when 'k' # okuri nashi kanji entry
             ["Ik:" + userid + ":", keyword.downcase]
           when 'K' # okuri ari   kanji entry
             ["IK:" + userid + ":", keyword]
           when 'h' # hiragana phrase entry
             ["Ih:" + userid + ":", keyword.downcase]
           else
             raise sprintf( "Error: ApproximateSearch#search unknown type %s ", type )
           end
    prefix   = pair[0]
    _keyword = pair[1]
    trie = DistributedTrie::Trie.new( kvs, prefix )
    trie.fuzzySearch( _keyword, @jarow_shikii )
  end
end
