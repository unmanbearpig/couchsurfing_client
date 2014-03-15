# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'couchsurfing_client/version'

Gem::Specification.new do |spec|
  spec.name          = "couchsurfing_client"
  spec.version       = CouchSurfingClient::VERSION
  spec.authors       = ["unmanbearpig"]
  spec.email         = ["unmanbearpig@gmail.com"]
  spec.summary       = %q{Unofficial Couchsurfing client}
  #  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/unmanbearpig/couchsurfing_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "awesome_print"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "mechanize", "~> 2.6.0"
end
