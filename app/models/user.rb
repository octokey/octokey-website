class User < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :email, :public_keys, :name

end
