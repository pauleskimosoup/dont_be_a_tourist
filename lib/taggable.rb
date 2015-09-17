module Taggable
  module ClassMethods

    def all_tags_array
      ((@default_tags || []) + all_tag_objects_array.collect(&:name)).uniq
    end

    def all_tag_objects_array
      tag_ids = Tagging.find(:all,
                             :select => "DISTINCT tag_id",
                             :conditions => {:taggable_type => self.to_s}).
                             collect{ |tagging| tagging.tag_id}
      ( Tag.find(tag_ids))
    end

    def all_tags
      all_tags_array.join ", "
    end

    private
    def model_ids(tag_string)
      tag = Tag.find_by_name(tag_string.strip)
      model_ids = nil
      if tag
        #model_ids = Tagging.find_by_sql(["SELECT DISTINCT taggable_id from taggings where taggable_type = '#{self.to_s}' and tag_id = ?", tag.id]).collect(&:taggable_id).join(",")
        model_ids = Tagging.find(:all,
                                 :select => "DISTINCT taggable_id",
                                 :conditions => {:taggable_type => self.to_s, :tag_id => tag.id}).
                                 collect(&:taggable_id).join(",")
      end
      if model_ids && model_ids != ""
        model_ids
      else
          '0'
      end
    end
  end

  def self.included(base)
    base.after_save :write_tags
    base.extend ClassMethods
    base.has_many :taggings, :as => :taggable, :dependent => :destroy
    base.named_scope :find_tagged, lambda{|tag|
      {:conditions => "id in (#{base.send :model_ids, tag})"}
    }
  end

  def tag_objects_array
    tag_ids = []
    self.taggings.map{|tagging| tag_ids << tagging.tag_id}
    Tag.find(tag_ids)
  end

  def tag_array
    tag_objects_array.collect{ |tag| tag.name}
  end

  def tags
    unless new_record?
      taggings.reload
    end
    tag_array.join ", "
  end

  def tags=(input)
    @temp_tags=input
    unless new_record?
      @temp_tags.strip!
      if @temp_tags != ""
        write_tags
      end
    end
  end

  def write_tags
    if !@temp_tags.nil?
      self.taggings.map(&:destroy)
      tag_arr = @temp_tags.split ","
      tag_arr.map do |tag_string|
        unless (tag_string = tag_string.strip) == ""
          self.taggings.create(
                               :tag_id => Tag.find_or_create_by_name(tag_string.strip).id
                               )
        end
      end
    end
    true
  end

  def tagged?(tag)
    tag_array.include?(tag)
  end

end
