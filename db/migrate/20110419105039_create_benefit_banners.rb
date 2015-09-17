class CreateBenefitBanners < ActiveRecord::Migration
  
  def self.up
    create_table :benefit_banners do |t|
      t.string    :title
      t.string    :quote
      t.text      :description
      t.integer   :picture1_id
      t.string    :page
      t.boolean   :display
      t.string    :created_by
      t.string    :updated_by
      t.datetime  :last_updated
      t.timestamps
    end
  end

  def self.down
    drop_table :benefit_banners
  end
  
end
