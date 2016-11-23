class CreateInterestPoints < ActiveRecord::Migration
  def change
    create_table :interest_points do |t|
      t.belongs_to :picture, index: true
      t.float :x
      t.float :y

      t.timestamps null: false
    end
  end
end
