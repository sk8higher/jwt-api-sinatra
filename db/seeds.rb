# frozen_string_literal: true

# require_relative './models/user'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

User.delete_all

10.times do |i|
  user = User.create(refresh_token: nil, email: "test#{i}@ya.ru")
  puts "Created user with ID #{user.id}"
end
