class TripGroup < ActiveRecord::Base

  include ActionView::Helpers::NumberHelper
  include Tp2Mixin
  include ImageHolder

  before_destroy :delete_slug


  has_friendly_id :name, :use_slug => true
  has_many :trips
  validates_presence_of :name, :summary
  validates_inclusion_of :rating, :in => ["0 Stars", "1 Star", "2 Stars", "3 Stars", "4 Stars", "5 Stars"], :message => "{{value}} is not a valid rating"

  def delete_slug
    slug.destroy
  end
end
