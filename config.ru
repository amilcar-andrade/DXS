$stdout.sync = true
require "rubygems"
require "bundler"

Bundler.require

require "./app"
run Sinatra::Application
