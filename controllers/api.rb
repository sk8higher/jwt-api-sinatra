require 'json'
require 'jwt'
require 'sinatra/base'

class Api < Sinatra::Base
  get '/tokens' do
    user = User.where(:id => params[:user_id])

    if user.exists?
      user.to_json
    else
      halt 404
    end
  end
end
