class Document < ActiveRecord::Base
  belongs_to :topic, touch: true
  has_attached_file :item
  has_paper_trail

  validates_attachment :item, :presence => true,
    :size => { :less_than => 11.megabytes, :message => "must be no more than 10MB" }
  do_not_validate_attachment_file_type :item

  def friendly_name
    return File.basename(item.original_filename, '.*').titleize unless item.nil? || item.original_filename.nil?
    ''
  end
end
