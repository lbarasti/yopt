# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yopt/version'

Gem::Specification.new do |spec|
  spec.name          = "yopt"
  spec.version       = Yopt::VERSION
  spec.authors       = ["lorenzo.barasti"]

  spec.summary       = %q{Scala-inspired Options for the idiomatic Rubyist}
  spec.description   = %q{The Option type models the possible absence of a value. It lets us deal with the uncertainty related to such a value being there without having to resort to errors or conditional blocks.}
  spec.homepage      = "http://lbarasti.github.io/yopt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.8"
end
