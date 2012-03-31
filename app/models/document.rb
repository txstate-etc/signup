class Document < ActiveRecord::Base
  belongs_to :topic
  has_attached_file :item
  validates_attachment_presence :item
  validates_attachment_size :item, :less_than => 11.megabytes, :message => "must be no more than 10MB"
  
  def friendly_name
    return File.basename(item.original_filename, '.*').titleize unless item.nil? || item.original_filename.nil?
    ''
  end
end
