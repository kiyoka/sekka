# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sekka"
  s.version = "1.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kiyoka Nishiyama"]
  s.date = "2014-04-30"
  s.description = "Sekka is a SKK like input method. Sekka server provides REST Based API. If you are SKK user, let's try it."
  s.email = "kiyoka@sumibi.org"
  s.executables = ["sekka-jisyo", "sekka-server", "sekka-benchmark", "sekka-path"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gemtest",
    "COPYING",
    "Rakefile",
    "VERSION.yml",
    "bin/sekka-benchmark",
    "bin/sekka-jisyo",
    "bin/sekka-path",
    "bin/sekka-server",
    "emacs/http-cookies.el",
    "emacs/http-get.el",
    "emacs/popup.el",
    "emacs/sekka.el",
    "lib/sekka.ru",
    "lib/sekka/alphabet-lib.nnd",
    "lib/sekka/approximatesearch.rb",
    "lib/sekka/convert-jisyo.nnd",
    "lib/sekka/google-ime.nnd",
    "lib/sekka/henkan.nnd",
    "lib/sekka/jisyo-db.nnd",
    "lib/sekka/kvs.rb",
    "lib/sekka/path.rb",
    "lib/sekka/roman-lib.nnd",
    "lib/sekka/sekkaversion.rb",
    "lib/sekka/sharp-number.nnd",
    "lib/sekka/util.nnd",
    "lib/sekkaconfig.rb",
    "lib/sekkaserver.rb",
    "script/sekkaserver.debian",
    "test/alphabet-lib.nnd",
    "test/approximate-bench.nnd",
    "test/azik-verification.nnd",
    "test/common.nnd",
    "test/google-ime.nnd",
    "test/henkan-bench.nnd",
    "test/henkan-main.nnd",
    "test/jisyo.nnd",
    "test/memcache.nnd",
    "test/redis.nnd",
    "test/roman-lib.nnd",
    "test/sekka-dump-out-1.txt",
    "test/sekka-jisyo-out-1.txt",
    "test/sharp-number.nnd",
    "test/skk-azik-table.nnd",
    "test/skk-jisyo-in-1.txt",
    "test/util.nnd"
  ]
  s.homepage = "http://github.com/kiyoka/sekka"
  s.licenses = ["New BSD"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.0.14"
  s.summary = "Sekka is a SKK like input method."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, ["~> 1.0"])
      s.add_runtime_dependency(%q<memcache-client>, ["~> 1.8"])
      s.add_runtime_dependency(%q<nendo>, ["= 0.7.0"])
      s.add_runtime_dependency(%q<distributed-trie>, ["= 0.8.0"])
      s.add_runtime_dependency(%q<rack>, ["~> 1.5"])
      s.add_runtime_dependency(%q<ruby-progressbar>, ["~> 1.4"])
      s.add_runtime_dependency(%q<eventmachine>, ["~> 1.0"])
      s.add_runtime_dependency(%q<memcache-client>, ["~> 1.8"])
      s.add_runtime_dependency(%q<nendo>, ["= 0.7.0"])
      s.add_runtime_dependency(%q<distributed-trie>, ["= 0.8.0"])
      s.add_runtime_dependency(%q<rack>, ["~> 1.5"])
      s.add_runtime_dependency(%q<ruby-progressbar>, ["~> 1.4"])
    else
      s.add_dependency(%q<eventmachine>, ["~> 1.0"])
      s.add_dependency(%q<memcache-client>, ["~> 1.8"])
      s.add_dependency(%q<nendo>, ["= 0.7.0"])
      s.add_dependency(%q<distributed-trie>, ["= 0.8.0"])
      s.add_dependency(%q<rack>, ["~> 1.5"])
      s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
      s.add_dependency(%q<eventmachine>, ["~> 1.0"])
      s.add_dependency(%q<memcache-client>, ["~> 1.8"])
      s.add_dependency(%q<nendo>, ["= 0.7.0"])
      s.add_dependency(%q<distributed-trie>, ["= 0.8.0"])
      s.add_dependency(%q<rack>, ["~> 1.5"])
      s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
    end
  else
    s.add_dependency(%q<eventmachine>, ["~> 1.0"])
    s.add_dependency(%q<memcache-client>, ["~> 1.8"])
    s.add_dependency(%q<nendo>, ["= 0.7.0"])
    s.add_dependency(%q<distributed-trie>, ["= 0.8.0"])
    s.add_dependency(%q<rack>, ["~> 1.5"])
    s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
    s.add_dependency(%q<eventmachine>, ["~> 1.0"])
    s.add_dependency(%q<memcache-client>, ["~> 1.8"])
    s.add_dependency(%q<nendo>, ["= 0.7.0"])
    s.add_dependency(%q<distributed-trie>, ["= 0.8.0"])
    s.add_dependency(%q<rack>, ["~> 1.5"])
    s.add_dependency(%q<ruby-progressbar>, ["~> 1.4"])
  end
end

