# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yell/adapters/logstash/version'

Gem::Specification.new do |spec|
  spec.name          = "yell-adapters-logstash"
  spec.version       = Yell::Adapters::Logstash::VERSION
  spec.authors       = ["mihai-aupeo"]
  spec.email         = ["mihai@aupeo.com"]
  spec.summary       = %q{LogStash adapter for Yell}
  spec.description   = %q{LogStash adapter for Yell}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'yell'
  spec.add_dependency 'logstash-event'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
