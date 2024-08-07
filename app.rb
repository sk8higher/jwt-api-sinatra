require 'sinatra'
require 'mongoid'

require_relative './models/user'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

get '/' do
  user = User.create!
  user.to_json
end
