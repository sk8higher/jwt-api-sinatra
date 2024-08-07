class JwtAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      options = { algorithm: 'HS512', iss: ENV['JWT_ISSUER'] }
      bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
      payload, header = JWT.decode(bearer, ENV['JWT_SECRET'], true, options)

      env[:user_id] = payload['user_id']
      @app.call env
    rescue JWT::DecodeError
      [401, { 'content-type' => 'text/plain' }, ['A token must be passed.']]
    rescue JWT::ExpiredSignature
      [403, { 'content-type' => 'text/plain' }, ['The token has expired.']]
    rescue JWT::InvalidIssuerError
      [403, { 'content-type' => 'text/plain' }, ['The token does not have a valid issuer.']]
    rescue JWT::InvalidIatError
      [403, { 'content-type' => 'text/plain' }, ['The token does not have a valid "issued at" time.']]
    end
  end
end
