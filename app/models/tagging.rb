class Tagging < ActiveRecord::Base

  has_one :tag
  belongs_to :taggable, :polymorphic => true

end
