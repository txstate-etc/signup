cache({:action => :show, :format => :atom, :action_suffix => "#{date_slug}"}, :tag => 'session-info') do
  atom_feed(:root_url => tag_url(@tag)) do |feed|
    feed.title(t(:'.atom_title_prefix') + @page_title)
    updated = @topics.max { |a, b| a.upcoming_sessions[0].updated_at <=> b.upcoming_sessions[0].updated_at } rescue nil
    feed.updated(updated ? updated.upcoming_sessions[0].updated_at : Time.now)

    @topics = Topic.upcoming_tagged_with(@tag)
    if @topics.size > 0
      @topics.each do |topic|
        cache(["tags/show/upcoming/atom", "#{date_slug}", topic], :tag => topic.cache_key) do
          next unless topic.upcoming_sessions.present?
          published = topic.upcoming_sessions.max { |a, b| a.updated_at <=> b.updated_at } rescue nil
          feed.entry(topic, :published => published.updated_at) do |entry|
            entry.title(topic.name)
            
            summary = []
            
            topic.upcoming_sessions.first(2).each do |session|
              summary << link_to_session(session)
            
              # FIXME: add topic description, instructor, location, etc
              #entry.content(session_info(session))
            end
            
            more = topic.upcoming_sessions.size - 2
            summary << link_to("#{more} more upcoming sessions", topic) if more > 0
            
            entry.summary(summary.join("<br/>\n"))

          end
        end
      end
    else
      # FIXME: should we display anything when there are no upcoming sessions?
    end
  end
end
