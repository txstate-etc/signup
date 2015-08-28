cache(["#{sess_key}/#{date_slug}/#{sites_key}/departments/show/upcoming/atom", @department], expires_in: 1.day) do
  atom_feed(:root_url => department_url(@department)) do |feed|
    feed.title(t(:'.atom_title_prefix') + @page_title)
    @topics = @department.upcoming
    updated = @topics.max { |a, b| a.upcoming_sessions[0].updated_at <=> b.upcoming_sessions[0].updated_at } rescue nil
    time = updated.upcoming_sessions.first.updated_at rescue nil
    feed.updated(time ? time : Time.now)

    if @topics.size > 0
      @topics.sort_by(&:next_time).each do |topic|
        session = topic.upcoming_sessions.first
        next unless session
        cache(["#{sites_key}/departments/show/upcoming/atom", session.topic, session]) do
          feed.entry(session, updated: session.time, published: session.time) do |entry|
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
