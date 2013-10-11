class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references  :team_one, index: true
      t.references  :team_two, index: true
      t.integer    :team_one_score
      t.integer    :team_two_score
      t.integer    :team_one_accepted_results
      t.integer    :team_two_accepted_results
      t.timestamps
    end
  end
end
