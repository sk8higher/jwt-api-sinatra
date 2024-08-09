require 'bcrypt'
require 'base64'
require 'json'
require 'jwt'
require 'sinatra/base'

class Api < Sinatra::Base
  get '/tokens' do
    content_type :json

    @user = User.find(params[:user_id])

    if @user.nil?
      halt 404, { error: 'User not found.' }.to_json
    else
      {
        access_token: @user.generate_access_token(request.ip),
        refresh_token: @user.generate_refresh_token(request.ip)
      }.to_json
    end
  end

  post '/refresh' do
    content_type :json

    refresh_token = params[:refresh_token]
    access_token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)

    decoded_access_token = decode_jwt(access_token)

    user_id = decoded_access_token['user']['user_id']

    @user = User.find_by(id: user_id)

    new_access_token = @user.refresh_access_token(refresh_token, request.ip)

    send_email(@user.email) if decoded_access_token['user']['ip'] != request.ip

    if new_access_token.nil?
      halt 401, { error: 'Invalid refresh_token' }.to_json
    else
      {
        access_token: new_access_token
      }.to_json
    end
  end

  private

  def decode_jwt(token)
    begin
      options = { algorithm: 'HS512', iss: ENV['JWT_ISSUER'] }
      payload, header = JWT.decode(token, ENV['JWT_SECRET'], true, options)

      payload
    rescue JWT::DecodeError
      halt 401, { error: "A token must be passed. #{e.message}" }.to_json
    rescue JWT::ExpiredSignature
      halt 403, { error: 'The token has expired.' }.to_json
    rescue JWT::InvalidIssuerError
      halt 403, { error: 'The token does not have a valid issuer.' }.to_json
    rescue JWT::InvalidIatError
      halt 403, { error: 'The token does not have a valid "issued at" time.' }.to_json
    end
  end
end
