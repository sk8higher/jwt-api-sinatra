require_relative './models/user'
require 'mongoid'

namespace :db do
  task :seed do
    Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

    User.delete_all

    10.times do |i|
      user = User.create(refresh_token: nil, email: "test#{i}@ya.ru")
      puts "Created user with ID #{user.id}"
    end
  end
end
