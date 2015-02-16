class DelimiterParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      # FIXME: we used to split on white space. No More?
      tag_list.add @tag_list.to_s.split(/,|;/).map(&:titleize)
    end
  end
end

ActsAsTaggableOn.remove_unused_tags = true
ActsAsTaggableOn.force_lowercase = true
ActsAsTaggableOn.force_parameterize = true
ActsAsTaggableOn.default_parser = DelimiterParser
