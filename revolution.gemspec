# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'revolution/version'

Gem::Specification.new do |spec|
  spec.name     = 'revolution'
  spec.version  = Revolution::VERSION
  spec.authors  = ['Grindr']
  spec.email    = 'grindrlabs@grindr.com'
  spec.licenses = ['MIT', 'Apache-2.0']

  spec.summary  = 'Automated RPM builds'
  spec.homepage = 'https://github.com/grindrlabs/revolution'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16.1'
  spec.add_development_dependency 'rake', '~> 12.1.0'
  spec.add_development_dependency 'rspec', '~> 3.6.0'
  spec.add_development_dependency 'rubocop', '~> 0.49.1'
  spec.add_runtime_dependency 'aws-sdk', '~> 3'
  spec.add_runtime_dependency 'fpm-cookery', '~> 0.33.0'
  spec.add_runtime_dependency 'rugged', '~> 0.26.0'
  spec.add_runtime_dependency 'thor', '~> 0.20.0'
end
