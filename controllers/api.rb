require 'json'
require 'jwt'
require 'sinatra/base'

class Api < Sinatra::Base
  get '/tokens' do
    user = User.find(params[:user_id])

    unless user.nil?
      content_type :json
      { access_token: access_token(user[:id]) }.to_json
    else
      halt 404
    end
  end

  private

  def access_token(user_id)
    JWT.encode(payload(user_id), ENV['JWT_SECRET'], 'HS512')
  end

  def payload(user_id)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        user_id: user_id
      }
    }
  end
end
