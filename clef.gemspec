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

  s.add_dependency "faraday", "~> 0.9.0"
  s.add_dependency "faraday_middleware", "~> 0.10.0"
  s.add_dependency 'activesupport', '>= 4.0.0', '<5.0.0'


  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr", "~> 2.9.3"
  s.add_development_dependency "webmock", "~> 1.21.0"
end
