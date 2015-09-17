ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!( :default => '%d/%m/%Y',
  :date_time12  => "%m/%d/%Y %I:%M%p",
  :date_time24  => "%m/%d/%Y %H:%M")

require "calendar_date_select"
CalendarDateSelect.format = :euro_24hr