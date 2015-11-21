# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ez7gen/version'

Gem::Specification.new do |spec|
  spec.name          = "ez7gen"
  spec.version       = Ez7gen::VERSION
  spec.authors       = ["Roman Sova"]
  spec.email         = ["sova.roman@gmail.com"]
  spec.summary       = %q{HL7 Test Message Generator}
  spec.description   = %q{Generate HL7 test messages, according to Ensemble schema}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # spec.add_runtime_dependency 'json', '1.7.7'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rerun' #,'0.10.0'
  spec.add_development_dependency 'thin' #, '1.6.2'

end
