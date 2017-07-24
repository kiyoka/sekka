# downloader.rb  -  "downloader for SEKKA-JISYO data"
#
#   Copyright (c) 2017  Kiyoka Nishiyama  <kiyoka@sumibi.org>
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

require 'net/http'
require 'uri'
require 'tmpdir'
require 'digest'

class Downloader
  def initialize( url, savepath = nil )
    @url_str = url
    @body = nil
  end

  def download()
    url = URI.parse(@url_str)
    if(url)
      req = Net::HTTP::Get.new(url.path)
      http = Net::HTTP.new(url.host,url.port)
      if url.scheme == 'https'
        http.use_ssl = true
      end
      res = http.request(req)
      @body = res.body
    end
    return @body
  end

  def downloadToFile(path)
    url = URI.parse(@url_str)
    req = Net::HTTP::Get.new url.path
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.use_ssl = true
    end
    http.request req do |response|
      open path, 'w' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end

  def getBodySize()
    size = 0
    if @body
      size = @body.size
    end
    return size
  end

  def getBody()
    return @body
  end

  def saveAs(path)
    open(path,"w") {|f|
      f.write(@body)
    }
  end

  def clearBody()
    @body = nil
  end

  def calcMD5()
    Digest::MD5.hexdigest @body
  end
  
end
