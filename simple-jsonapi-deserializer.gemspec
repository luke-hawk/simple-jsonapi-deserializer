# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_jsonapi_deserializer/version'

Gem::Specification.new do |gem|
  gem.name          = 'simple-jsonapi-deserializer'
  gem.version       = SimpleJSONAPIDeserializer::VERSION
  gem.summary       = ''
  gem.description   = ''
  gem.license       = 'MIT'
  gem.authors       = ['Gerrit Seger']
  gem.email         = 'gerrit.seger@gmail.com'
  gem.homepage      = 'https://rubygems.org/gems/simple-jsonapi-deserializer'

  gem.files         = `git ls-files`.split($/)

  `git submodule --quiet foreach --recursive pwd`.split($/).each do |submodule|
    submodule.sub!("#{Dir.pwd}/",'')

    Dir.chdir(submodule) do
      `git ls-files`.split($/).map do |subpath|
        gem.files << File.join(submodule,subpath)
      end
    end
  end
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.10'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rdoc', '~> 4.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rspec_snapshot_matcher', '~> 0.1.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
end
