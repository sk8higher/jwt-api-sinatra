require 'bcrypt'
require 'base64'
require 'json'
require 'jwt'
require 'sinatra/base'

class Api < Sinatra::Base
  get '/tokens' do
    content_type :json

    @user = User.find(params[:user_id])

    unless @user.nil?
      {
        access_token: access_token(@user[:id], request.ip),
        refresh_token: refresh_token(@user[:id], request.ip)
      }.to_json
    else
      halt 404, { error: 'User not found.' }.to_json
    end
  end

  post '/refresh' do
    content_type :json

    refresh_token = params[:refresh_token]
    access_token = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)

    decoded_access_token = decode_jwt(access_token)

    user_id = decoded_access_token['user']['user_id']

    @user = User.find_by(id: user_id)

    if @user && valid_refresh_token?(refresh_token)
      if decoded_access_token['user']['ip'] != request.ip
        send_email(@user.email)
      end
      {
        access_token: access_token(@user[:id], request.ip)
      }.to_json
    else
      halt 401, { error: 'Invalid refresh_token' }.to_json
    end
  end

  private

  def access_token(user_id, ip)
    JWT.encode(payload(user_id, 'access', ip), ENV['JWT_SECRET'], 'HS512')
  end

  def refresh_token(user_id, ip)
    raw_token = JWT.encode(payload(user_id, 'refresh', ip), ENV['JWT_SECRET'], 'HS512')
    hashed_token = BCrypt::Password.create(raw_token)

    @user.update(refresh_token: hashed_token)

    Base64.encode64(raw_token)
  end

  def refresh_access_token(refresh_token, ip)
    return nil unless valid_refresh_token?(refresh_token)

    @user = User.find(params[:user_id])

    access_token(@user[:id], ip)
  end

  def valid_refresh_token?(refresh_token)
    hashed_token = @user.refresh_token
    return false if hashed_token.empty? || hashed_token.nil?

    BCrypt::Password.new(hashed_token) == Base64.decode64(refresh_token)
  end

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

  def send_email(email)
    # TODO
  end
end
