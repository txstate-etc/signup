class FileIcon
  
  BASE_ICON_PATH = 'fileicons'
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
    FileIcon.ext_map[@extension] || DEFAULT_ICON_PATH
  end
  
  private
  def self.fileicon_assets
    files = Dir.glob("#{Rails.application.assets_manifest.directory}/#{BASE_ICON_PATH}/*.png")
    if files.empty? && Rails.application.assets
      files = Rails.application.assets.paths.map {|d| Dir.glob("#{d}/#{BASE_ICON_PATH}/*.png")}.flatten
    end
    files
  end

  def self.init_ext_map
    ext_map = {}
    AUDIO_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'audio' }
    VIDEO_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'video' }
    IMAGE_EXTENSIONS.each { |ext| ext_map[ext] = ICON_PATH_TEMPLATE % 'image' }
    fileicon_assets.each do |file|
      ext = File.basename(file, '.png').gsub(/-.*/,'')
      ext_map[ext] = ICON_PATH_TEMPLATE % ext
    end 
    ext_map     
  end

  def self.ext_map
    @@ext_map ||= FileIcon.init_ext_map
  end

end
