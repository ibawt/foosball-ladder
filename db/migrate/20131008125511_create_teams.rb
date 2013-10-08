class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.references :player_one
      t.references :player_two
      t.timestamps
    end
  end
end
