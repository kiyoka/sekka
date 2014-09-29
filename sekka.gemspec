# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
puts lib
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sekka/sekkaversion'
Gem::Specification.new do |spec|
  spec.name          = "sekka"
  spec.version       = SekkaVersion::version
  spec.authors       = ["Kiyoka Nishiyama"]
  spec.email         = ["kiyoka@sumibi.org"]
  spec.summary       = %q{Sekka is a SKK like input method.}
  spec.description   = %q{Sekka is a SKK like input method. Sekka server provides REST Based API. If you are SKK user, let's try it.}
  spec.homepage      = "http://github.com/kiyoka/sekka"
  spec.license       = "New BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency "eventmachine", "~> 1.0"
  spec.add_dependency "memcache-client", "~> 1.8"
  spec.add_dependency "nendo", "= 0.7.1"
  spec.add_dependency "distributed-trie", "= 0.8.0"
  spec.add_dependency "rack",  "~> 1.5"
  spec.add_dependency "ruby-progressbar", "~> 1.4"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
