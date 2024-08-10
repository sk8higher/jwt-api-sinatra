# frozen_string_literal: true

require_relative './../spec_helper'
require_relative './../../models/user'
require 'base64'
require 'mongoid'

Mongoid.load!(File.join(File.dirname(__FILE__), '../../', 'config', 'mongoid.yml'))
Mongoid.raise_not_found_error = false

# rubocop:disable Metrics/BlockLength
RSpec.describe Api do
  before(:all) do
    @user = User.create!(email: 'test@test.ru')
  end

  describe 'GET /api/tokens' do
    it 'returns 404 if user is not found' do
      get '/tokens', user_id: 'test'

      expect(last_response.status).to eq 404
      expect(last_response.body).to include('User not found.')
    end

    it 'returns 200 and tokens if user is found' do
      get '/tokens', user_id: @user[:id]

      expect(last_response.status).to eq 200
      expect(last_response.body).to include('access_token')
    end
  end

  describe 'POST /api/refresh' do
    it 'returns 200 and new access token if tokens are correct' do
      get '/tokens', user_id: @user[:id]

      response = JSON.parse(last_response.body)
      access_token = response['access_token']
      refresh_token = response['refresh_token']

      header 'authorization', "Bearer #{access_token}"

      post '/refresh', { user_id: @user[:id], refresh_token: refresh_token }

      expect(last_response.status).to eq 200
      expect(last_response.body).to include('access_token')
    end

    it 'returns 401 if access token is not passed for an existing user' do
      post 'refresh', { user_id: @user[:id] }

      expect(last_response.status).to eq 401
      expect(last_response.body).to include 'A token must be passed.'
    end

    it 'returns 401 if the refresh token is not valid' do
      get '/tokens', user_id: @user[:id]

      response = JSON.parse(last_response.body)
      access_token = response['access_token']
      refresh_token = Base64.strict_encode64('test')

      header 'authorization', "Bearer #{access_token}"

      post '/refresh', { user_id: @user[:id], refresh_token: refresh_token }

      expect(last_response.status).to eq 401
      expect(last_response.body).to include('Invalid refresh_token')
    end
  end
end

# rubocop:enable Metrics/BlockLength
