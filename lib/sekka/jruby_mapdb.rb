# jruby_mapdb.rb  -  "wrapper library for MapDB(java)"
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
#
require '/tmp/guava-22.0.jar'
require '/tmp/elsa-3.0.0-M7.jar'
require '/tmp/kotlin-stdlib-jre8-1.1.2-3.jar'
require '/tmp/kotlin-compiler-1.1.2-3.jar'
require '/tmp/google-collections-1.0.jar'
require '/tmp/eclipse-collections-8.2.0.jar'
require '/tmp/eclipse-collections-api-8.2.0.jar'
require '/tmp/lz4-1.3.0.jar'
require '/tmp/mapdb-3.1.0-SNAPSHOT.jar'

module OrgMapdb
  include_package "org.mapdb"
end

module MapDB
  class Tree
    def initialize(treeobj)
      @treeobj = treeobj
    end
    def keys
      @treeobj.key_set.to_a
    end
    def put(key,value)
      @treeobj[key] = value
    end
    def get(key)
      @treeobj[key]
    end
  end

  class DB
    attr_reader :mapdb, :type
    def initialize(dbname=nil,treename=nil)
      @tree = nil
      if dbname.nil?
        @type = :MemoryDB
        @mapdb = OrgMapdb::DBMaker.
                   memoryDB().
                   closeOnJvmShutdown().
                   make()
      else
        @type = :FileDB
        @mapdb = OrgMapdb::DBMaker.
                   fileDB(Java::JavaIo::File.new("#{dbname}")).
                   closeOnJvmShutdown().
                   make()
      end
      if treename.nil?
        raise ArgumentError("require treename.")
      end
      tree = @mapdb.treeMap("#{treename}").createOrOpen()
      @tree = MapDB::Tree.new(tree)
    end

    def getTree()
      return @tree
    end

    def close
      @mapdb.close
    end
  end
end
