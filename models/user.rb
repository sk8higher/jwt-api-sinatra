require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :refresh_token, type: String
end
