cache(["#{date_slug}/departments/show/upcoming/atom", @department], :tag => 'session-info') do
  atom_feed(:root_url => department_url(@department)) do |feed|
    feed.title(t(:'.atom_title_prefix') + @page_title)
    @topics = @department.upcoming
    updated = @topics.max { |a, b| a.upcoming_sessions[0].updated_at <=> b.upcoming_sessions[0].updated_at } rescue nil
    time = updated.upcoming_sessions.first.updated_at rescue nil
    feed.updated(time ? time : Time.now)

    if @topics.size > 0
      @topics.each do |topic|
        session = topic.upcoming_sessions[0]
        next unless session
        cache(["departments/show/upcoming/atom", session], :tag => session.cache_key) do
          feed.entry(session, :published => session.time) do |entry|
            entry.title(topic.name)
            
            summary = "#{session_info(session)} — #{session.site.name}"
            
            entry.summary(summary)
            
            # FIXME: add topic description, instructor, location, etc
            #entry.content(session_info(session))
          end
        end
      end
    else
      # FIXME: should we display anything when there are no upcoming sessions?
    end
  end
end
