# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alkanet/agent/version'

Gem::Specification.new do |spec|
  spec.name          = "alkanet-agent"
  spec.version       = Alkanet::Agent::VERSION
  spec.authors       = ["Kosaka Yuki"]
  spec.email         = ["ykosaka@asl.cs.ritsumei.ac.jp"]

  spec.summary       = %q{Auto logging agent for alkanet server}
  spec.description   = %q{Auto logging agent for alkanet server}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.9.2"
  spec.add_dependency "faraday_middleware-multi_json", "~> 0.0.6"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
