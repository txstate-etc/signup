ActsAsTaggableOn::Tag.class_eval do
  def to_param
    "#{name.parameterize}"
  end
end
