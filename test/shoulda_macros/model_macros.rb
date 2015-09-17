class Test::Unit::TestCase
  def self.should_be_tp2_model
    model_class = self.name.gsub(/Test$/, '').constantize
    should_have_class_methods :paginate_and_order, :includes, :order, :conditions, :random_n, :displayable
  end
end
