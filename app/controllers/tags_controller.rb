class TagsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    #FIXME: Tag Cloud?
    @page_title = "All Tags"
  end

  def show
    tag_param = params[:id]
    if tag_param =~ /^\d+/
      @tag = ActsAsTaggableOn::Tag.find( tag_param )
    else
      @tag = ActsAsTaggableOn::Tag.find_by_name!( tag_param )
    end

    @page_title = "Topics Tagged With '" + @tag.name + "'"
    respond_to do |format|
      format.html
      format.atom
      if authorized? @tag
        format.csv do
          data = cache(['#{sess_key}/tags/csv', @tag], expires_in: 1.day) do
            topics = Topic.tagged_with(@tag).active
            Topic.to_csv(topics)
          end
          send_csv data, @tag.name 
        end
      end
    end
  end

end
