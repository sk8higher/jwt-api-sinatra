require 'bcrypt'
require 'json'
require 'jwt'
require 'sinatra/base'

class Api < Sinatra::Base
  get '/tokens' do
    @user = User.find(params[:user_id])

    unless @user.nil?
      content_type :json
      {
        access_token: access_token(@user[:id], request.ip),
        refresh_token: refresh_token(@user[:id], request.ip)
      }.to_json
    else
      halt 404
    end
  end

  private

  def access_token(user_id, ip)
    JWT.encode(payload(user_id, 'access', ip), ENV['JWT_SECRET'], 'HS512')
  end

  def refresh_token(user_id, ip)
    if @user.refresh_token.empty?
      @user.refresh_token = BCrypt::Password.create(JWT.encode(payload(user_id, 'refresh', ip), ENV['JWT_SECRET'], 'HS512'))
      @user.save
    end
    @user.refresh_token
  end

  def payload(user_id, type, ip)
    {
      exp: type == 'access' ? Time.now.to_i + 60 * 60 : Time.now.to_i + 60 * 360,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        user_id: user_id,
        ip: ip
      }
    }
  end
end
