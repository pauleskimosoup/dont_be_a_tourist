class CreateAccommodations < ActiveRecord::Migration
  def self.up
    create_table :accommodations do |t|
      t.string :name
      t.text :summary
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :accommodations
  end
end
