ActsAsTaggableOn::Tag.class_eval do
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
