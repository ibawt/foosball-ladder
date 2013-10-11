class Team < ActiveRecord::Base
  has_many :users

  has_many :team_ones, :class_name => 'Match', :foreign_key => 'team_one_id'
  has_many :team_twos, :class_name => 'Match', :foreign_key => 'team_two_id'

  def get_matches( needs_action )
    Match.where( '(team_one_id = ? or team_two_id = ?) and (team_one_score IS NULL or team_two_score IS NULL)', id, id )
  end
end
