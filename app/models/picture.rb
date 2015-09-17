class Picture < ActiveRecord::Base

  include Taggable
  @default_tags = []
  DIRECTORY = RAILS_ROOT + '/public/images/gallery'
  THUMB_DIR = File.join(DIRECTORY, "thumb")
  RESIZED_DIR = File.join(DIRECTORY, "resized")
  LARGE_DIR = File.join(DIRECTORY, "original")
  CROP_DIR1 = File.join(DIRECTORY, "crop_1")
  CROP_DIR2 = File.join(DIRECTORY, "crop_2")
  CROP_DIR3 = File.join(DIRECTORY, "crop_3")
  CROP_DIR4 = File.join(DIRECTORY, "crop_4")
  CROP_DIR5 = File.join(DIRECTORY, "crop_5")
  CROP_DIR6 = File.join(DIRECTORY, "crop_6")

  before_save :check_file_data
  before_save :process
  after_destroy :cleanup

  include TimeStampable
  before_save :time_stamp

  belongs_to :picture
  has_many :pictures


  require "RMagick"
  include Magick

  def self.tidy
    Picture.all.each {|x| x.destroy if Picture.destroyable(x.id)}
  end

  def self.destroyable(image_id)
    logger.debug "Can Picture #{self.id} be deleted?"
    picture_in_use = true
    Dir.glob(RAILS_ROOT + '/app/models/*.rb').each { |file| require file }
    for model in Object.subclasses_of(ActiveRecord::Base)
      current_class = (eval "#{model}")
      if current_class.methods.inspect.include? 'image_holder' then
        for object in current_class.find_by_sql("SELECT * FROM #{current_class.table_name}")
          if object.picture_ids.include?(image_id)
            picture_in_use = false
          end
          end
      end
     end
     logger.debug "#{picture_in_use}"
    return picture_in_use
  end

  def file_data=(file_data)
    unless file_data.size == 0
      @file_data = file_data
      write_attribute 'filename', file_data.original_filename
    end
  end

  def self.clean
    pwd = Dir.pwd
    Dir.chdir THUMB_DIR
    for file in Dir["*"]
      logger.debug "deleting file: #{file}"
      puts "deleting file: #{file}"
      File.unlink(File.join(THUMB_DIR, file))
    end
    Dir.chdir RESIZED_DIR
    for file in Dir["*"]
      logger.debug "deleting file: #{file}"
      puts "deleting file: #{file}"
      File.unlink(File.join(RESIZED_DIR, file))
    end
    Dir.chdir LARGE_DIR
    for file in Dir["*"]
      logger.debug "deleting file: #{file}"
      puts "deleting file: #{file}"
      File.unlink(File.join(LARGE_DIR, file))
    end
    Dir.chdir pwd
  end

  def check_file_data
    @file_data
  end

  def content_type
    case self.extension
    when ".jpg", ".jpe", ".jpeg"
      "jpeg"
    when ".gif"
      "gif"
    when ".png"
      "x-png"
    end
  end

  def path
    File.join(DIRECTORY, "#{self.filename}")
  end

  def large_path
    File.join(LARGE_DIR, "#{self.filename}")
  end

  def self.thumb_path
    THUMB_DIR
  end

  def url(width = 0, height = 0)
    if width != 0 || height != 0
      "/images/gallery/resized/#{self.resize(width, height)}"
    else
      "/images/gallery/#{self.filename}"
    end
  end

  def original_url
    "/images/gallery/original/#{self.filename}"
  end

  def crop_url(crop_number = 1)
    begin
      result = "/images/gallery/crop_#{crop_number}/#{self.filename}"
      Magick::ImageList.new(File.join(DIRECTORY, "crop_#{crop_number}/#{self.filename}"))
    rescue
      result = nil
    end
    return result
  end

  def resize(width=nil, height=nil, options = {})
    options = { :stretchp => nil, :file_path => nil}.merge(options)
    if width == 0
      width = nil
    end
    if height == 0
      height = nil
    end
    if self.exists?
      new_filename = self.new_filename(width, height)
      unless File.exists?(Picture.file_path(new_filename))

        image = ImageList.new(self.original_path)
        iw = image.columns
        ih = image.rows

        if width and height

          if height.to_f/width.to_f >= ih.to_f/iw.to_f
            image.change_geometry!("x" + height.to_s) {|w, h, img| img.resize!(w, h)}
          else
            image.change_geometry!(width.to_s) {|w, h, img| img.resize!(w, h)}
          end
          image.crop!(CenterGravity, width, height)

        elsif width and image.columns > width
          image.change_geometry!(width.to_s) do |w, h, img|
            img.resize!(w, h)
          end
        elsif height and image.rows > height
          image.change_geometry!("x" + height.to_s) do |w, h, img|
            img.resize!(w, h)
          end
        end
        image.write(File.join(RESIZED_DIR, new_filename))
      end
      if options[:file_path]
        File.join(RESIZED_DIR, new_filename)
      else
        new_filename
      end
    end
  end

  def new_filename(width=nil, crop_height=nil)
    logger.debug "new_filename"
    if !filename
      return ""
    elsif not (width or height)
      self.filename
    else
      split = self.filename.split(".")
      new_filename = split[0...split.length-1].join
      new_filename += "w" + width.to_s
      if crop_height
        new_filename += "h" + crop_height.to_s
      end
      new_filename +=  "." + split.last
      new_filename
    end
  end

  def Picture.increment_count(filename)
    base = get_basename(filename)
    logger.debug "base = " + base
    split = base.split("_")
    if split.last.to_i == 0
      ret = split.join("_") + "_1" + get_extension(filename)
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Picture.increment_count(ret)
      else
        ret
      end
    else
      split[split.length-1] = (split[split.length-1].to_i + 1).to_s
      ret = split.join("_")  + get_extension(filename)
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Picture.increment_count(ret)
      else
        ret
      end
    end
  end

  def Picture.get_extension(filename)
    filename[filename.rindex(".")..filename.length]
  end

  def extension
    Picture.get_extension(self.filename)
  end

  def Picture.get_basename(filename)
    filename[0...filename.rindex(".")]
  end

  def exists?
    File.exists?(self.original_path)
  end

  def Picture.original_path(filename="")
    "#{RAILS_ROOT}/public/images/gallery/#{filename}"
  end

  def Picture.file_path(filename="")
    "#{RAILS_ROOT}/public/images/gallery/resized/#{filename}"
  end

  def original_path
    Picture.original_path(self.filename)
  end

  def file_path
    Picture.file_path(self.filename)
  end

  def Picture.image_url(filename="")
    "/images/gallery/#{filename}"
  end

  def image_url
    Picture.image_url(self.filename)
  end

  def width_and_height
    if self.exists?
      img = Magick::Image::read(self.original_path).first
      [img.columns, img.rows]
    else
      [0, 0]
    end
  end

  def width
    self.width_and_height[0]
  end

  def original_width
    img = Magick::Image::read(self.large_path).first
    img.columns
  end

  def resized_width(height = 100)
    img = Magick::Image::read(File.join(RESIZED_DIR, self.resize(nil, height))).first
    img.columns
  end

  def height
    self.width_and_height[1]
  end

  def original_height
    img = Magick::Image::read(self.large_path).first
    img.rows
  end

  def resized_height(width = 100)
    img = Magick::Image::read(File.join(RESIZED_DIR, self.resize(width, nil))).first
    img.rows
  end


  def Picture.in_use(file)
    in_use = false
    Picture.find(:all).each do |picture|
      unless in_use
        if file.index(Picture.get_basename(picture.filename))
          in_use = true
        end
      end
    end
    in_use
  end

  def collect_garbage
    Dir.foreach("#{RAILS_ROOT}/public/images/gallery/resized") do |file|
      unless [".", ".."].index(file)
        if file =~ Regexp.new(Picture.get_basename(self.filename))
          File.delete("#{RAILS_ROOT}/public/images/gallery/resized/#{file}")
        end
      end
    end
  end

  def after_destroy
    collect_garbage
  end

  def cleanup
    begin
      File.unlink(File.join(DIRECTORY, "#{self.filename}"))
    rescue
      logger.info "could not delete file #{self.filename}"
    end
    begin
      File.unlink(File.join(CROP_DIR1, "#{self.filename}"))
    rescue
    end
    begin
      File.unlink(File.join(CROP_DIR2, "#{self.filename}"))
    rescue
    end
    begin
      File.unlink(File.join(CROP_DIR3, "#{self.filename}"))
    rescue
    end
    begin
      File.unlink(File.join(CROP_DIR4, "#{self.filename}"))
    rescue
    end
    begin
      File.unlink(File.join(CROP_DIR5, "#{self.filename}"))
    rescue
    end
    begin
      File.unlink(File.join(CROP_DIR6, "#{self.filename}"))
    rescue
    end
  end

  def crop(params)
    begin
      require 'RMagick'
      image = Magick::ImageList.new(self.path)
      x = params[:crop_x].to_i
      y = params[:crop_y].to_i
      w = params[:crop_w].to_i
      h = params[:crop_h].to_i
    crop = image.crop(x,y,w,h)
    crop.write("#{RAILS_ROOT}/public/images/gallery/crop_#{params['crop']}/#{self.filename}")
    return true
  rescue
    return false
  end
  end

  def crop_master(params)
    begin
      require 'RMagick'
      image = Magick::ImageList.new(self.large_path)
      x = params["crop_x#{self.id}"].to_i
      y = params["crop_y#{self.id}"].to_i
      w = params["crop_w#{self.id}"].to_i
      h = params["crop_h#{self.id}"].to_i
      unless params["crop_x#{self.id}"].include? 'x'
        crop = image.crop(x,y,w,h)
      crop.write("#{RAILS_ROOT}/public/images/gallery/#{self.filename}")
      crop.write("#{RAILS_ROOT}/public/images/gallery/original/#{self.filename}")
      return true
    else
      return false
    end
  rescue
    return false
  end
  end

  private

  def process
    if @file_data
      save_file
      @file_data = nil
    end
  end

  def save_file
    logger.debug "content_type = " + @file_data.content_type
    if @file_data.content_type =~ /^image/
      filename = @file_data.original_filename
      if File.exists?(self.path)
        logger.debug "incrementing count"
        self.filename = Picture.increment_count(filename)
      end
      File.open(self.large_path, "wb") do |f|
        logger.info "writing file"
        f.write(@file_data.read)
      end
      logger.info "Large Path: #{self.large_path}"
      # this code is specifically for resizing the image if it is too large
      image = ImageList.new(self.large_path)

        #raise self.large_path.to_yaml
      image.density = "72x72"
      image.write(self.large_path)
      if (image.columns > 750) or (image.rows > 550)
        image.change_geometry!("750x550") {|cols, rows, img|
          img.resize!(cols, rows)
        }
      end
      image.write(self.path)

    end

  end

end
