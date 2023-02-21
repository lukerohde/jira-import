require 'io/console'
require 'pry-byebug'
require 'optparse'
require 'json'
require 'bundler'
Bundler.require(:default)

require './application'
app = Application.new

#app.test()
