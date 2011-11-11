# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "scope_filter"
  s.version     = '0.9.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lars Kuhnt"]
  s.email       = ["lars.kuhnt@gmail.com"]
  s.homepage    = "http://github.com/larskuhnt/scope_filter"
  s.summary     = "ActiveRecord filter- and search-library using scopes"
  s.description = "scope_filter is a filter- and search-library for ActiveRecord models using scopes"
 
  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "guard-rspec"
 
  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md ROADMAP.md)
  s.require_path = 'lib'
end
