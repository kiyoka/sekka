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
require 'forwardable'
require '/usr/local/stow/ruby-1.7.27-jruby/lib/ruby/gems/shared/gems/jruby-mapdb-1.2.0-java/lib/mapdb-0.9.8.jar'

module Jruby
  module Mapdb
    module ClassMethods
      include Enumerable
      extend Forwardable
      def encode(key, value)
        @tree.put key, Marshal.dump(value).to_java_bytes
      end
      def decode(key)
        stored = @tree.get(key)
        return nil if stored.nil?
        Marshal.load String.from_java_bytes(stored)
      end
      def each
        @tree.each_pair { |key,value| yield(key, Marshal.load(String.from_java_bytes(value))) }
      end
      def keys
        @tree.key_set.to_a
      end
      def regexp(pattern)
        re = Regexp.new "#{pattern}", Regexp::EXTENDED | Regexp::IGNORECASE
        @tree.select{ |k,v| "#{k}" =~ re }.map(&:first)
      end
      def_delegator :@tree, :clear,    :clear
      def_delegator :@tree, :has_key?, :key?
      def_delegator :@tree, :count,    :size
      alias :[]=   :encode
      alias :[]    :decode
      alias :count :size
      def put(key,value)
        @tree[key] = value
      end
      def get(key)
        @tree[key]
      end
    end
    class Tree
      extend ClassMethods
    end
    class DB
      extend Forwardable
      attr_reader :mapdb, :type
      def initialize(dbname=nil,treename=nil)
        if dbname.nil?
          @type = :MemoryDB
          @mapdb = Java::OrgMapdb::DBMaker.
                     newMemoryDB().
                     closeOnJvmShutdown().
                     make()
        else
          @type = :FileDB
          @mapdb = Java::OrgMapdb::DBMaker.
                     newFileDB(Java::JavaIo::File.new("#{dbname}")).
                     closeOnJvmShutdown().
                     transactionDisable().
                     mmapFileEnable().
                     asyncWriteEnable().
                     make()
        end
        if treename.nil?
          raise ArgumentError("require treename.")
        end
        @tree = @mapdb.treeMap("#{treename}").createOrOpen()
        p @tree
        @tree
      end
      def trees
        Hash[*(@mapdb.getAll.map(&:first).map(&:to_sym).zip(@mapdb.getAll.map(&:last).map(&:size)).flatten)]
      end
      def_delegators :@mapdb, :close, :closed?, :compact
    end
  end
end

