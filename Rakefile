#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'
begin
  require 'rakefile' # http://github.com/bendiken/rakefile
rescue LoadError => e
end
require 'rack/throttle'

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec)

task :default => :spec