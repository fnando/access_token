require './lib/access_token/version'

Gem::Specification.new do |spec|
  spec.name          = 'access_token'
  spec.version       = AccessToken::VERSION
  spec.authors       = ['Nando Vieira']
  spec.email         = ['fnando.vieira@gmail.com']

  spec.summary       = 'Access token for client-side and API authentication.'
  spec.description   = spec.summary
  spec.homepage      = 'http://rubygems.org/gems/access_token'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'parsel'
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-utils'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'bcrypt'
  spec.add_development_dependency 'pry-meta'
  spec.add_development_dependency 'redis'
  spec.add_development_dependency 'dalli'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
