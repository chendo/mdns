# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mdns/version'

Gem::Specification.new do |spec|
  spec.name          = "mdns"
  spec.version       = MDNS::VERSION
  spec.authors       = ["Jack Chen (chendo)"]
  spec.email         = ["github+mdns@chen.do"]
  spec.summary       = %q{Create your own .local address with mdns!}
  spec.description   = %q{mdns allows you to create your own .local hostnames and point them to whatever IP you want.}
  spec.homepage      = "https://github.com/chendo/mdns"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
