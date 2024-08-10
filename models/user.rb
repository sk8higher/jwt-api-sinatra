require 'jwt'
require 'base64'
require 'bcrypt'
require 'mongoid'
require 'mail'

class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :refresh_token, type: String
  field :email, type: String

  def generate_access_token(ip)
    JWT.encode(payload('access', ip), ENV['JWT_SECRET'], 'HS512')
  end

  def generate_refresh_token(ip)
    raw_token = JWT.encode(payload('refresh', ip), ENV['JWT_SECRET'], 'HS512')
    hashed_token = BCrypt::Password.create(raw_token)

    update(refresh_token: hashed_token)

    Base64.strict_encode64(raw_token)
  end

  def refresh_access_token(refresh_token, ip)
    return nil unless valid_refresh_token?(refresh_token)

    update(refresh_token: nil)

    generate_access_token(ip)
  end

  def valid_refresh_token?(refresh_token)
    hashed_token = self[:refresh_token]

    return false if hashed_token.nil?

    BCrypt::Password.new(hashed_token) == Base64.strict_decode64(refresh_token)
  end

  def send_email(ip)
    Mail.defaults do
      delivery_method :smtp, {
        address: "smtp.gmail.com",
        port: 587,
        user_name: ENV['EMAIL_APP_USERNAME'],
        password: ENV['EMAIL_APP_PASSWORD'],
        authentication: :plain,
        enable_starttls_auto: true
      }
    end

    Mail.deliver do
      from 'apitestingjwtauth@gmail.com'
      to self[:email]
      subject 'Warning! Your access token has been refreshed from a new IP'
      body "Your access token has been refreshed from this IP address: #{ip}."
    end
  end

  private

  def payload(type, ip)
    {
      exp: type == 'access' ? Time.now.to_i + 60 * 60 : Time.now.to_i + 60 * 360,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        user_id: self[:id],
        ip: ip
      }
    }
  end
end
