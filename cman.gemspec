# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cman/version'

Gem::Specification.new do |spec|
  spec.name          = "cman"
  spec.version       = Cman::VERSION
  spec.authors       = ["mbme"]
  spec.email         = ["stribog.ua@gmail.com"]
  spec.summary       = %q{small configs manager}
  spec.description   = %q{small configs manager}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"

  spec.add_dependency "json"

  spec.required_ruby_version = ">= 2.0"
end
