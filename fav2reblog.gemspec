# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fav2reblog/version'

Gem::Specification.new do |spec|
  spec.name          = "fav2reblog"
  spec.version       = Fav2reblog::VERSION
  spec.authors       = ["Issei Naruta"]
  spec.email         = ["mimitako@gmail.com"]
  spec.summary       = %q{When fav some tweets which include image(s), then post it to tumblr}
  spec.description   = %q{When fav some tweets which include image(s), then reblog it to tumblr.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency 'twitter', '~> 5.8.0'
  spec.add_dependency 'tumblr_client'
end
