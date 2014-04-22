class TagsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    #FIXME: Tag Cloud?
    @page_title = "All Tags"
  end

  def show
    begin
      tag_param = params[:id]
      if tag_param =~ /^\d+/
        @tag = ActsAsTaggableOn::Tag.find( tag_param )
      else
        @tag = ActsAsTaggableOn::Tag.find_by_name!( tag_param )
      end
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @tag
      return
    end

    @page_title = "Topics Tagged With '" + @tag.name + "'"
    respond_to do |format|
      format.html
      format.atom
      if authorized? @tag
        data = cache ['tags/csv', @tag], :tag => 'session-info' do 
          topics = Topic.tagged_with(@tag).active
          Topic.to_csv(topics)
        end
        format.csv { send_csv data, @tag.name }
      end
    end
  end

end
