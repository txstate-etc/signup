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
        format.csv do
          key = fragment_cache_key(['tags/csv', @tag])
          data = Rails.cache.fetch(key) do 
            Cashier.store_fragment(key, 'session-info')
            topics = Topic.tagged_with(@tag).active
            Topic.to_csv(topics)
          end
          send_csv data, @tag.name 
        end
      end
    end
  end

end
