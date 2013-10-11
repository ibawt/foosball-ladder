class AddRatingToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :rating, :integer, :default => 1200
  end
end
