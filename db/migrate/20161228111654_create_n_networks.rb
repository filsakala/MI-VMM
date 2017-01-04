class CreateNNetworks < ActiveRecord::Migration
  def change
    create_table :n_networks do |t|
      t.string :name
      t.float :learning_rate
      t.integer :repeat_cnt
      t.text :weights, limit: 256000

      t.timestamps null: false
    end
  end
end
