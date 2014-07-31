# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pry-ib/version'

Gem::Specification.new do |spec|
  spec.name          = "pry-ib"
  spec.version       = PryIb::VERSION
  spec.authors       = ["David Kinsfather"]
  spec.email         = ["david.kinsfather@gmail.com"]
  spec.description   = %q{This pry plugin provides a CLI to interact with the Interactive Brokers TWS API with the ib-ruby gem}
  spec.summary       = %q{A CLI for trading with Interative Brokers}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
