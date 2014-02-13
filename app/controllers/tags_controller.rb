class TagsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    #FIXME: Tag Cloud?
    @page_title = "All Tags"
  end

  def show
    begin
      @tag = ActsAsTaggableOn::Tag.find( params[ :id ] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @tag
      return
    end

    @topics = Topic.upcoming_tagged_with(@tag)
    @all_topics = Topic.tagged_with(@tag).active
    @page_title = "Topics Tagged With '" + @tag.name + "'"
    respond_to do |format|
      format.html
      format.atom
      format.csv { send_csv Topic.to_csv(@all_topics), @tag.name }
    end
  end

end
