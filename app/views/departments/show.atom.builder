atom_feed(:root_url => department_url(@department)) do |feed|
  feed.title(t(:'.atom_title_prefix') + @page_title)
  updated = @topics.min { |a, b| a.upcoming_sessions[0].updated_at <=> b.upcoming_sessions[0].updated_at }
  feed.updated(updated ? updated.upcoming_sessions[0].updated_at : Time.now)

  # FIXME: sort the sessions the same way that the html page does
        # Gato sorts by publish date, newest to oldest.

  if @topics.size > 0
    for topic in @topics
      session = topic.upcoming_sessions[0]
      feed.entry(session, :published => session.time) do |entry|
        entry.title(topic.name)
        
        summary = "#{session_info(session)} — #{session.site.name}"
        
        entry.summary(summary)
        
        # FIXME: add topic description, instructor, location, etc
        #entry.content(session_info(session))
      end
    end
  else
    # FIXME: should we display anything when there are no upcoming sessions?
  end
end
