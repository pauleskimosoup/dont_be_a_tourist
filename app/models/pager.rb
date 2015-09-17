class Pager

  attr_accessor :previous_page, :next_page, :range, :count, :num_pages, :page

  def Pager.pages(paged_class_or_list, page=1, page_size=10, options={})
    if page.nil?
      page = 1
    end
    if paged_class_or_list.kind_of?(Array)
      Pager.list_pages(paged_class_or_list, page, page_size)
    elsif paged_class_or_list.kind_of?(Class)
      Pager.class_pages(paged_class_or_list, page, page_size, options)
    end
  end

  def Pager.class_pages(paged_class, page=1, page_size=10, options={ })
    all = paged_class.find(:all, :conditions => options[:conditions], :order => options[:order], :include => options[:includes], :offset => (page.to_i-1) * page_size, :limit => page_size)
    length = paged_class.count(:conditions => options[:conditions], :include => options[:includes])
    return all, Pager.new(page, page_size, length)
  end

  def Pager.list_pages(list, page, page_size)
    return list[(page.to_i - 1) * page_size ... page.to_i * page_size], Pager.new(page, page_size, list.length)
  end

  def initialize(page, page_size, length)
    if page
      self.page = page.to_i
      self.previous_page = page.to_i - 1 unless (page.to_i < 2)
      self.next_page = page.to_i + 1 unless (page.to_i * page_size) >= length
      self.range = "#{((page.to_i - 1) * page_size) + 1} to #{[length, page.to_i * page_size].min}"
    end
    self.count = length
    self.num_pages = (length.to_f/page_size.to_f).ceil
  end

end
