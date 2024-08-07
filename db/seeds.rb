require_relative '../models/user'

User.delete_all

10.times do
  user = User.create
  puts "Created user with ID #{user.id}"
end
