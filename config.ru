# frozen_string_literal: true

require './app'

run Rack::URLMap.new({
                       '/api' => Api
                     })
