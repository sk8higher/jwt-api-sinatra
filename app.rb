require 'sinatra'
require 'mongoid'

require_relative './models/user'
require_relative './controllers/api'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))
