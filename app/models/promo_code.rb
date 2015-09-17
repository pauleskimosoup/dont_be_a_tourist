class PromoCode < ActiveRecord::Base

  include Tp2Mixin
  include PromoCodeHelper

  has_and_belongs_to_many :linked_promo_codes, :class_name => "PromoCode", :foreign_key => "main_promo_code_id", :association_foreign_key => "linked_promo_code_id", :join_table => "linked_promo_codes"
  has_and_belongs_to_many :products
  has_and_belongs_to_many :users
  has_and_belongs_to_many :splash_pages
  has_one :basket

  named_scope :active, :conditions => {:active => true}
  named_scope :automatic, :conditions => {:activation_type => 2}
  named_scope :in_date, lambda{ { :conditions => ["? >= start_date AND ? <= end_date", Date.today, Date.today] } }
  named_scope :splash, :conditions => {:activation_type => 3}

  validates_presence_of :code, :if => Proc.new{|x| x.requires_code? }
  validates_uniqueness_of :code, :if => Proc.new{|x| x.requires_code? }

  validate :custom_validations
  def custom_validations
    if saving_value.blank? && days_discount.blank?
      errors.add_to_base("In the \"Saving\" section, you must specify one of the two options.")
    end
  end

  def active?
    Date.today >= start_date && Date.today <= end_date
  end

  def code_type?
    activation_type == 1
  end

  def requires_code?
    activation_type == 3 || activation_type == 1
  end

  def self.activation_types
    [
    ['User enters code', 1],
    ['Automatically applied', 2],
    ['Splash page', 3]
    ]
  end

  def activation_type_name
    for type in PromoCode.activation_types
      return type.first if type.last == activation_type
    end
    return 'Unknown'
  end

  def self.reward_types
    [
    ['Single reward to entire basket if all conditions are met',1],
    ['Reward applied to basket every time conditions are met', 2]
    ]
  end

  def reward_type_name
    for type in PromoCode.reward_types
      return type.first if type.last == reward_type
    end
    return 'Unknown'
  end


  def self.default_attributes
   {:start_date => 10.year.ago, :end_date => 10.year.from_now}
  end

  def name_and_saving_for(basket)
    all_names = []
    total_saving = 0
    all_ids = []
    basket_items_used = []
    days_used = 0

    codes_to_check = linked_promo_codes + [self]
    codes_to_check = codes_to_check.reject{|x| x.activation_type == 1 && x != basket.promo_code }

    logger.info "LOOKING AT THESE CODES:"
    for promo_code in codes_to_check
      logger.info "--- #{promo_code.description}"
    end

    for promo_code in codes_to_check
      logger.info "----------------------------------------"
      logger.info "NOW LOOKING AT #{promo_code.description}"
      code_saving, code_basket_items_used, code_days_used = promo_code.get_saving_and_basket_items_used_and_days_used(basket, basket_items_used, days_used)
      if code_saving > 0
        if uses_up_bookings?
          code_basket_items_used.each{|x| basket_items_used << x}
          days_used += code_days_used
        end
        total_saving += code_saving
        all_names << promo_code.description
        all_ids << promo_code.id
      end
      logger.info "DONE LOOKING AT #{promo_code.description}"
      logger.info "-----------------------------------------"
    end

    return [all_names.uniq.join(', '), all_ids, total_saving]
  end

  def get_saving_and_basket_items_used_and_days_used(basket, basket_items_used=[], days_used=0)
    logger.info "taking a close look at #{description} with #{basket_items_used.length} basket items used and #{days_used} days used."
    basket_items = basket.basket_items.reject{|x| basket_items_used.include?(x)}
    saving = 0

    if active? && (!first_booking? || (first_booking? && !basket.user.nil? && basket.user.never_booked_before?))

      if days_condition?
        valid_days = get_matching_basket_items(basket_items, self).collect{|x| x.trip.length }.sum
        if (valid_days - days_used) >= days_condition
          days_used += days_condition
          if days_discount?
            saving += apply_day_discount(basket.basket_items, self)
          elsif saving_target == 'basket'
            saving += apply_basket_saving(basket, self)
          elsif saving_target == 'items'
            saving += apply_matching_items_saving(basket.basket_items, self)
          elsif saving_target == 'item'
            cheapest = basket.basket_items.sort_by{|x| x.subtotal}.first
            saving += apply_matching_items_saving([cheapest], self)
          end
        end
      else

        if days_discount?
          saving += apply_day_discount(basket.basket_items, self)
        elsif saving_target == 'basket'
          if basket_conditions_met?(basket_items, self)
            logger.info "applying basket saving"
            saving += apply_basket_saving(basket, self)
          else
            logger.info "did not meet conditions to apply basket saving"
          end
        elsif saving_target == 'items'
          basket_items = get_matching_basket_items(basket_items, self)
          basket_items_used = basket_items
          saving += apply_matching_items_saving(basket_items, self)
        elsif saving_target == 'item'
          basket_items = get_matching_basket_items(basket_items, self)
          basket_items_used = basket_items
          cheapest = basket_items.sort_by{|x| x.subtotal}.first
          if cheapest
            saving += apply_matching_items_saving([cheapest], self)
          end
        end
      end
    end

    logger.info "total saving for this code is #{saving}"

    return saving, basket_items_used, days_used
  end

end
