class Document < ActiveRecord::Base

  DIRECTORY = RAILS_ROOT + '/public/documents'
  before_save :check_file_data
  after_save :process
  after_destroy :cleanup

  include TimeStampable
  before_save :time_stamp

  def file_data=(file_data)
    unless file_data.size == 0
      @file_data = file_data
      write_attribute 'filename', file_data.original_filename
    end
  end

  def check_file_data
    @file_data
  end

  def path
    File.join(DIRECTORY, "#{self.filename}")
  end

  def url
    "/documents/#{self.filename}"
  end

  def Document.increment_count(filename)
    base = get_basename(filename)
    split = base.split("_")
    split = base.split("_")
    if split.last.to_i == 0
      ret = split.join("_") + "_1" + get_extension(filename)
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Document.increment_count(ret)
      else
        ret
      end
    else
      split[split.length-1] = (split[split.length-1].to_i + 1).to_s
      ret = split.join("_")  + get_extension(filename)
      puts ret
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Document.increment_count(ret)
      else
        ret
      end
    end
  end

  def Document.get_extension(filename)
    filename[filename.rindex(".")..filename.length]
  end

  def Document.get_basename(filename)
    filename[0...filename.rindex(".")]
  end

  def exists?
    File.exists?(self.path)
  end

  private

  def process
    if @file_data
      save_file
      @file_data = nil
    end
  end

  def save_file
    if @file_data
      filename = @file_data.original_filename
      if File.exists?(self.path)
        self.filename = Document.increment_count(filename)
      end
      File.open(self.path, "wb") do |f|
        f.write(@file_data.read)
      end
      self.filename = filename
    end

  end

end
