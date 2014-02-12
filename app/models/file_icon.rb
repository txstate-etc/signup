class FileIcon
  
  BASE_ICON_PATH = 'fileicons'
  DIR_PATH = "#{Rails.root}/public/images/#{BASE_ICON_PATH}"
  ICON_PATH_TEMPLATE = "#{BASE_ICON_PATH}/%s.png"
  DEFAULT_ICON_TYPE = 'file'
  DEFAULT_ICON_PATH = ICON_PATH_TEMPLATE % DEFAULT_ICON_TYPE
  
  AUDIO_EXTENSIONS = %w{ aac aif iff mp3 mpa ra wav wma }
  VIDEO_EXTENSIONS = %w{ 3g2 3gp asf asx avi flv m4v mov mp4 mpg rm swf vob wmv }
  IMAGE_EXTENSIONS = %w{ bmp eps gif jpeg jpg png svg tiff }

  def self.icon_path(filename)
    FileIcon.new(filename).icon_path
  end

  def initialize(filename)
    @extension = File.extname(filename).delete('.')
  rescue
    @extension = nil
  end

  def type
    @extension
  end
  
  def icon_path
    EXT_MAP[@extension] || DEFAULT_ICON_PATH
  end
  
  private
  def self.init_ext_map
    ext_map = {}
    AUDIO_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'audio' }
    VIDEO_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'video' }
    IMAGE_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'image' }
    Dir.glob("#{DIR_PATH}/*.png") do |file|
      ext = File.basename(file, '.png')
      ext_map[ext] = ICON_PATH_TEMPLATE % ext
    end 
    ext_map     
  end
  EXT_MAP = FileIcon.init_ext_map
end
