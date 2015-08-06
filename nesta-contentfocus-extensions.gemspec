# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nesta-contentfocus-extensions/version'

Gem::Specification.new do |spec|
  spec.name          = 'nesta-contentfocus-extensions'
  spec.version       = Nesta::ContentFocus::VERSION
  spec.authors       = ['Glenn Gillen']
  spec.email         = ['me@glenngillen.com']
  spec.summary       = 'A collection of extensions to the NestaCMS.'
  spec.description   = 'Extensions required to use ContentFocus themes.'
  spec.homepage      = 'https://contentfocus.io/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_runtime_dependency 'nesta', '>= 0.11.0'
  spec.add_runtime_dependency 'gemoji-parser', '~> 1.3.1'
  spec.add_runtime_dependency 'kramdown', '~> 1.5.0'
  spec.add_runtime_dependency 'neat', '~> 1.7.2'
  spec.add_runtime_dependency 'rouge', '~> 1.9.1'
  spec.add_runtime_dependency 'sass', '~> 3.4.16'
  spec.add_runtime_dependency 'sass_paths', '~> 1.0.1'
  spec.add_runtime_dependency 'sinatra-flash', '~> 0.3.0'
  spec.add_runtime_dependency 'sprockets', '~> 3.2.0'
  spec.add_runtime_dependency 'tilt', '~> 1.4.0'
  spec.add_runtime_dependency 'uglifier', '~> 2.7.1'
end
