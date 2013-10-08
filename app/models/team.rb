class Team < ActiveRecord::Base
  belongs_to :player_one, :class_name => 'User'
  belongs_to :player_two, :class_name => 'User'

  has_many :users
end
