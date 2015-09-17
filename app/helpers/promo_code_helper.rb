module PromoCodeHelper
  
  def reject_incorrect_types(basket_items, promo_code)
    logger.info "looking at #{basket_items.length} basket items to check types"
    if !promo_code.booking_condition_day? && !promo_code.booking_condition_overnight? && !promo_code.booking_condition_multinight?
      logger.info "booking conditions are not set"
      return basket_items
    else
      return basket_items.select{|basket_item| (promo_code.booking_condition_day? && basket_item.trip.day_trip?) || (promo_code.booking_condition_overnight? && basket_item.trip.overnight_trip?) || (promo_code.booking_condition_multinight? && basket_item.trip.multinight_trip?)}
    end
  end  
  
  def include_correct_type?(basket_items, promo_code)
    if !promo_code.booking_condition_day? && !promo_code.booking_condition_overnight? && !promo_code.booking_condition_multinight?
      logger.info "booking conditions are not set"
      return true
    else
      return !reject_incorrect_types(basket_items, promo_code).empty?
    end
  end
  
  def basket_conditions_met?(basket_items, promo_code)
    fail = false
    
    # booking total comes to right amount
    if promo_code.basket_total_condition? 
      fail = true unless basket_items.collect{|x| x.subtotal}.sum >= promo_code.basket_total_condition
    end
    logger.info "after looking at booking total conditions fail is #{fail}"
    
    # right number of people on a single trip
    if people_condition?
      trip_checks = []
      for trip in basket_items.collect{|x| x.trip }.uniq
        trip_checks << basket_items.select{|x| x.trip == trip }.length >= promo_code.people_condition?
      end
      fail = true unless trip_checks.include?(true)
    end
    logger.info "after looking at number of people on a single trip fail is #{fail}"
  
    # booking early
    if promo_code.early_condition? 
      fail = true unless basket_items.select{|x| Date.today + promo_code.early_condition < x.trip.start_date }.length > 0
    end
    logger.info "after looking at early booking conditions fail is #{fail}"
      
    # booking certain type
    fail = true unless include_correct_type?(basket_items, promo_code)
    logger.info "after looking at booking types conditions fail is #{fail}"
    
    # booking in not only incorrect types
    if promo_code.not_welcome?
      if basket_items.reject{|x| x.trip.welcome_trip? }.empty?
        fail = true
      end
      logger.info "after checking if there are trips which are not welcome trips fail is #{fail}"
    end
        
    return !fail
  end
  
  def apply_basket_saving(basket, promo_code)
    if promo_code.saving_type == 'pounds'
      return promo_code.saving_value
    elsif promo_code.saving_type == 'percent'
      return promo_code.saving_value.to_f * (basket.total_without_discount_less_upgrade_extras/100.0)
    end
  end
  
  def get_matching_basket_items(basket_items, promo_code)
  
    # booking certain type
    basket_items = reject_incorrect_types(basket_items, promo_code)
    
    # only welcome trip
    if promo_code.only_welcome?
      basket_items = basket_items.select{|x| x.trip.welcome_trip? }
      logger.info "only welcome condition check requested - after selecting only welcome trips down to #{basket_items.length} basket items"
    end
    
    # not welcome trip
    if promo_code.not_welcome?
      basket_items = basket_items.reject{|x| x.trip.welcome_trip? }
      logger.info "not welcome condition check requested - after rejecting welcome trips down to #{basket_items.length} basket items"
    end    

    # booking early
    if promo_code.early_condition?
      logger.info "early condition check requested (only bookings before #{Date.today + promo_code.early_condition} will be valid)"
      logger.info "starting with #{basket_items.length} basket items"
      bis = []
      for bi in basket_items
        logger.info "is #{Date.today + promo_code.early_condition} < #{bi.trip.start_date}?"
        if Date.today + promo_code.early_condition < bi.trip.start_date
          logger.info "yes"
          bis << bi
        else
          logger.info "no"
        end
      end
      basket_items = bis
      logger.info "after rejecting late bookings down to #{basket_items.length} basket items"
    end
        
    # right number of people on a single trip
    if people_condition?
      merge_items = []
      for trip in basket_items.collect{|x| x.trip }.uniq
        matching_basket_items = basket_items.select{|x| x.trip == trip }
        matching_basket_items.each{|x| merge_items << x} if matching_basket_items.length >= promo_code.people_condition
      end
      basket_items = merge_items & basket_items
      logger.info "people on trip check requested - after rejecting trips without enough people down to #{basket_items.length} basket items"
    end
    
    # booking total comes to right amount
    if promo_code.basket_total_condition? 
      basket_items = [] unless basket_items.collect{|x| x.subtotal }.sum >= promo_code.basket_total_condition
      logger.info "basket total check requested - after checking if basket total reaches correct amount down to #{basket_items.length} basket items"
    end
    
    # product conditions
    if promo_code.products.length > 0
      basket_items = basket_items.select{|x| !(promo_code.products & x.products).empty? }
    end
        
    logger.info "after matching what it wanted this code has used up #{basket_items.length} basket items" 
    
    return basket_items
        
  end
  
  def apply_matching_items_saving(basket_items, promo_code)
    saving = 0
    for basket_item in basket_items
      if promo_code.saving_type == 'pounds' 
        saving += promo_code.saving_value
      elsif promo_code.saving_type == 'percent'
        saving += promo_code.saving_value.to_f * (basket_item.subtotal_less_upgrade_extras/100.0)
      end
    end
    return saving
  end
  
  def apply_day_discount(basket_items, promo_code)
    possible_free_days = []
    for basket_item in basket_items
      day_on_this_trip_price = basket_item.trip_total.to_f / basket_item.trip.length
      basket_item.trip.length.times do
        possible_free_days << day_on_this_trip_price
      end
    end
    # because of the whole stupid extra thing
    possible_free_days = possible_free_days.sort
    if promo_code.days_condition?
      promo_code.days_condition.times do
        possible_free_days.pop
      end
    end
    return possible_free_days[0..days_discount-1].sum
  end  
end
