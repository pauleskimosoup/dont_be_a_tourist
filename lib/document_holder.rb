module DocumentHolder
#currently only has that one method. Might move some of the others in here if it seems to make sense.

  def self.included(base)
    document_columns = base.column_names.select{|col| col =~ /^document[0-9]*_id$/}
    document_columns.each do |col|
      n = col.gsub(/[^0-9]*/, "").to_i
      attribute_name = col.gsub("_id", "")
      base.belongs_to(attribute_name.to_sym, :class_name => "Document", :foreign_key => col)
      base.send(:define_method, "has_document#{n}?") { self.send(attribute_name.to_sym) && self.send(attribute_name.to_sym).exists? }

      base.send(:attr_accessor, ((attribute_name + '_file_data').to_sym))
      base.send(:attr_accessor, ((attribute_name + '_description').to_sym))
      base.send(:attr_accessor, ((attribute_name + '_remove').to_sym))
    end

    # add documents
    base.send(:define_method, "documents") { document_columns.map{ |col| self.send(col.gsub("_id", "").to_sym)}.compact}
    #here we were doing base.send(:before_save blah
    base.before_save :update_documents
  end

  def update_documents
    document_columns = self.attribute_names.select{|col| col =~ /^document[0-9]*_id$/}
    document_columns.each do |col|
      attribute_name = col.gsub("_id", "")
      if self.send((attribute_name+"_remove").to_sym) == "1"
        self.send((attribute_name+"=").to_sym, nil)
      end


      if self.send((attribute_name+ "_file_data").to_sym) && self.send((attribute_name+ "_file_data").to_sym).length != 0
          document = Document.create(:file_data => self.send((attribute_name+"_file_data").to_sym), :description => self.send((attribute_name+"_description").to_sym))
      end
      if document
        self.send((attribute_name+"=").to_sym, document)
      end
    end
  end

  def has_a_document?
    not self.documents.empty?
  end

end
