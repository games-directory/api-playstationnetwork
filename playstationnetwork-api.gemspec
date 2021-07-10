# coding: utf-8
require './lib/playstationnetwork/version'

Gem::Specification.new do |spec|
  spec.name          = 'playstationnetwork-api'
  spec.version       = PlayStationNetwork::VERSION
  spec.authors       = ['Vlad Radulescu']
  spec.email         = ['oss@games.directory']

  spec.summary       = %q{ [DEPRECATED] A Ruby wrapper around PSN Leaderboard's API }
  spec.description   = %q{ [DEPRECATED] Allows your app to communicate with the PlayStation Network API and retrieve your, or a given user, Games, Trophies and Achievements. API is provided by psnloaderboard.com . }
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 13.0'
end
