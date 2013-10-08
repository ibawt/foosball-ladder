class Team < ActiveRecord::Base
  attr_accessible :name

  belongs_to :player_one, :class_name => 'User'
  belongs_to :player_two, :class_name => 'User'

  has_many :users
end
