# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-release"
  spec.version       = CocoapodRelease::VERSION
  spec.authors       = ["Oliver Letterer"]
  spec.email         = ["oliver.letterer@gmail.com"]
  spec.summary       = %q{Tags and releases pods for you.}
  spec.description   = %q{Release helper plugin for CocoaPods.}
  spec.homepage      = "https://github.com/Sparrow-Labs/cocoapods-release"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
