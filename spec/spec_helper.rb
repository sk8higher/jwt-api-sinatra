# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative './../controllers/api'
require 'rack/test'
require 'rspec'

module RSpecMixin
  include Rack::Test::Methods

  def app
    @app = Api
  end
end

RSpec.configure { |c| c.include RSpecMixin }
