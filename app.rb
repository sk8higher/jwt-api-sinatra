# frozen_string_literal: true

require 'dotenv/load'

require 'sinatra'
require 'sinatra/activerecord'

require_relative './models/user'
require_relative './controllers/api'

set :database_file, 'config/database.yml'
