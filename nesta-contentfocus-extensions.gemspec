# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nesta-contentfocus-extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "nesta-contentfocus-extensions"
  spec.version       = Nesta::ContentFocus::VERSION
  spec.authors       = ["Glenn Gillen"]
  spec.email         = ["me@glenngillen.com"]
  spec.summary       = %q{A collection of extensions to the NestaCMS.}
  spec.description   = %q{Extensions to NestaCMS required to use ContentFocus or ContentFocus themes.}
  spec.homepage      = "https://contentfocus.io/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency 'nesta', '>= 0.11.0'
  spec.add_runtime_dependency 'redcarpet', '~> 3.2.2'
  spec.add_runtime_dependency 'tilt', '~> 1.4.0'
  spec.add_runtime_dependency 'pygments.rb', '~> 0.6.3'
  spec.add_runtime_dependency 'sass_paths', '~> 1.0.1'
end
