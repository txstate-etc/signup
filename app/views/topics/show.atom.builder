atom_feed(:root_url => topic_url(@topic)) do |feed|
  feed.title(t(:'.atom_title_prefix') + @page_title)
  sessions = @topic.upcoming_sessions
  updated = sessions.max { |a, b| a.updated_at <=> b.updated_at }
  feed.updated(updated ? updated.updated_at : Time.now)

  if sessions.size > 0
    for session in sessions
      feed.entry(session, :published => session.time) do |entry|
        title = "#{session_info(session)} — #{session.site.name}"
        entry.title(title)

        # FIXME: what should go in the summary tag?
        #entry.summary(?????)
        
        # FIXME: add topic description, instructor, location, etc
        #entry.content(session_info(session))
      end
    end
  else
    # FIXME: should we display anything when there are no upcoming sessions?
  end
end
