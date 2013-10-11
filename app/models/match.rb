class Match < ActiveRecord::Base
  belongs_to :team_one, :class_name => 'Team'
  belongs_to :team_two, :class_name => 'Team'

  def completed?
    team_one_accepted_results && team_two_accepted_results
  end
end
