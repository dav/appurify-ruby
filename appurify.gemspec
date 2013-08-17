$:.unshift File.expand_path("../lib", __FILE__)
require 'appurify/version'

Gem::Specification.new do |gem|
  gem.name          = "appurify"
  gem.version       = Appurify::VERSION
  gem.authors       = ["cisimple"]
  gem.email         = %w(team@cisimple.com)
  gem.description   = %q{API client for Appurify}
  gem.summary       = %q{Run tests using Appurify's mobile devices.}
  gem.homepage      = "https://github.com/cisimple-team/appurify"

  gem.files         = %x{ git ls-files }.split("\n").select{|d| d =~ %r{^(License|README|bin/|lib/)}}
  gem.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  gem.rdoc_options  = %w(--charset=UTF-8)

  gem.add_dependency 'rest-client', '~>1.6'
  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'fakeweb', '~> 1.30'
  gem.add_development_dependency 'timecop', '~> 0.60'
end
