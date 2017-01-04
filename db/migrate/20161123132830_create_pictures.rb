class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.belongs_to :n_network, index: true
      t.timestamps null: false
    end
    add_attachment :pictures, :image
  end

  # def up
  # end
  #
  # def down
  #   remove_attachment :pictures, :image
  # end
end
