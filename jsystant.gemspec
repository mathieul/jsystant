# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jsystant/version"

Gem::Specification.new do |s|
  s.name        = "jsystant"
  s.version     = Jsystant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mathieu Lajugie"]
  s.email       = ["jsystant@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{JavaScript project assistant that helps with structuring files and code.}
  s.description = s.summary

  s.rubyforge_project = "jsystant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency("thor",      "~> 0.14.6")
  s.add_dependency("compass",   "~> 0.10.6")
  s.add_dependency("nokogiri",  "~> 1.4.4")
end
