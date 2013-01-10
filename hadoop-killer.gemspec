# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hadoop-killer/version'

Gem::Specification.new do |gem|
  gem.name          = "hadoop-killer"
  gem.version       = Hadoop::Killer::VERSION
  gem.authors       = ["Tsuyoshi Ozawa"]
  gem.email         = ["ozawa.tsuyoshi@gmail.com"]
  gem.description   = %q{Kill hadoop daemons for debugging, testing, and development.}
  gem.summary       = %q{Hadoop daemons killer for easily debug, test, development}
  gem.homepage      = "https://github.com/oza/hadoop-killer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
