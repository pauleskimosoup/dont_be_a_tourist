module Tp2Mixin

  module ClassMethods
  	      	
  	def paginate_and_order(params, page_size=50)
      Pager.pages(self, params[:page], page_size, {:conditions => conditions(params), :order => order(params), :includes => includes})
    end

    def includes
      ret = []
      self.reflect_on_all_associations(:belongs_to).each do |ass|
        unless ass.options.has_key?(:as) || ass.options.has_key?(:polymorphic)
          ret << ass.name.to_sym
        end
      end
#      self.columns.select{|column| column.name =~ /_id/ }.each do |column|
#        ret << column.name.chomp("_id").to_sym
#      end
      ret
    end

    def order(params)

      if params[:order_field]
        dir = params[:order_direction] || "asc"
        if params[:order_field] =~ /_id/
	        params[:order_field] = params[:order_field].chomp "_id"
	        params[:order_field] = self.reflect_on_all_associations(:belongs_to).select{ |ass| ass.name == params[:order_field].to_sym}.first.name.to_s.pluralize + '.name'
        end
        unless params[:order_field].include? '.'
        	params[:order_field] = "#{self.table_name}.#{params[:order_field]}"
        end
        #return "`#{params[:order_field].split(".").join("`.`")}` #{dir}"
        return "#{params[:order_field]} #{dir}"
      else
        return "#{self.table_name}.id desc"
      end
    end

    def conditions(params)
      #raise self.columns.to_yaml
      if params[:conditions]
        query = params[:conditions]
      else
        query = "true"
      end
      if params[:search]
      	search_array = []
      	text_fields = self.columns.select{ |column| column.type == :string || column.type == :text  || column.type == :integer}
        text_fields.each do |field|
          search_array << "#{self.table_name}.#{field.name} LIKE :search"
        end
      	self.reflect_on_all_associations(:belongs_to).each{|ass| ass.klass.columns.select{|column| column.type == :string || column.type == :text  || column.type == :integer}.each{|column| search_array << "#{ass.klass.table_name}.#{column.name} LIKE :search"}}
        joined_search = search_array.join(" OR ")
        joined_search = joined_search.insert(0, '(')
        joined_search << ')'
        query = [query, joined_search].join " AND "
      end
      return [query, { :search => "%#{params[:search]}%"}]
    end

    def random_n(n=1)
      #mysql only you guys
      self.find(:all, :order => "RAND()", :limit => n)
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.named_scope(:displayable, :conditions => { :display => true})
  end

  def initialize(*params)
    super(*params)
  end
  

end
