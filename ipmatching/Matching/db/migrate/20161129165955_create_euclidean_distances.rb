class CreateEuclideanDistances < ActiveRecord::Migration
  def change
    create_table :euclidean_distances do |t|
      t.integer  :first_point_id
      t.integer  :second_point_id
      t.float :distance

      t.timestamps null: false
    end
  end
end
