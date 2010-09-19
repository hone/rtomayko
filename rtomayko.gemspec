# -*- encoding: utf-8 -*-
require File.expand_path("../lib/rtomayko/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rtomayko"
  s.version     = RTomayko::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Pedro Belo', 'Terence Lee']
  s.email       = ['pedrobelo@gmail.com', 'hone02@gmail.com']
  s.homepage    = "http://github.com/hone/rtomayko"
  s.summary     = "Simple acceptance testing, the skips all the tests after a failing test."
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "rtomayko"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

