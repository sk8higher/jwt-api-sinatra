require_relative './app'

run Rack::URLMap.new({
  '/api' => Api
})
