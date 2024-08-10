# frozen_string_literal: true

require_relative './app'

run Rack::URLMap.new({
                       '/api' => Api
                     })
