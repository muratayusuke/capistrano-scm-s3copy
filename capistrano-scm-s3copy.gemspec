# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/scm/s3copy/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-scm-s3copy"
  spec.version       = Capistrano::Scm::S3copy::VERSION
  spec.authors       = ["muratayusuke"]
  spec.email         = ["info@muratayusuke.com"]

  spec.summary       = %q{Copy to/from AWS S3 strategy for capistrano 3.x}
  spec.description   = %q{Copy to/from AWS S3 strategy for capistrano 3.x}
  spec.homepage      = "https://github.com/muratayusuke/capistrano-scm-s3copy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "capistrano", "~> 3.0"
  spec.add_runtime_dependency "aws-sdk", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
