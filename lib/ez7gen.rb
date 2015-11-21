#!/usr/bin/env ruby
#
#http://florianhanke.com/blog/2011/02/02/running-sinatra-inside-a-gem.html
# begin
#   require 'ez7gen/app.rb'
# rescue LoadError => e
#   require 'rubygems'
#   path = File.expand_path '../../lib', __FILE__
#   $:.unshift(path) if File.directory?(path) && !$:.include?(path)
#   require 'ez7gen/app.rb'
# end

require "ez7gen/version"
require "ez7gen/message_factory"
#
# module Ez7gen
#   class Generator
#     def generate(ver, event)
#       hl7 = MessageFactory.new.generate(ver, event)
#     end
#   end
# end
