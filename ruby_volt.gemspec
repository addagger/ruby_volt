require File.expand_path("../lib/ruby_volt/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ruby_volt"
  s.version     = RubyVolt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Valery Kvon"]
  s.email       = 'addagger@gmail.com'
  s.date        = '2019-05-09'
  s.homepage    = "https://github.com/addagger/ruby_volt"
  s.summary     = "VoltDB Wire Protocol Client for Ruby programming language"
  s.description = "Pure Ruby client for VoltDB - one of the fastest in-memory databases on the planet. Threadsafe and fast enough wire client implementation, based on protocol specifications Version 1 (01/26/2016)."
  s.required_ruby_version = '>= 2.5.0'
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "ruby_volt"

  # If you have other dependencies, add them here
  s.add_dependency "minitest", "~> 5.13"
  s.files        = Dir["{lib}/**/*.rb", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.license      = 'MIT'
end