# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'clef/version'

Gem::Specification.new do |s|
  s.name     = 'clef'
  s.version  = Clef::VERSION
  s.authors  = ['Jesse Pollak']
  s.email    = ['jesse@getclef.com']
  s.summary  = 'The Clef API wrapper for Ruby'
  s.description = 'The Clef API wrapper for Ruby'
  s.homepage = 'https://github.com/clef/clef-ruby'
  s.license = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency "httparty", "~> 0.13.5"
  s.add_dependency 'activesupport', '~> 3.2.12'

  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
end