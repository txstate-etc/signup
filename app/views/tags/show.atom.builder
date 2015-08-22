cache(["#{sess_key}/#{date_slug}/#{sites_key}/tags/show/upcoming/atom", @tag], expires_in: 1.day) do
  atom_feed(:root_url => tag_url(@tag)) do |feed|
    feed.title(t(:'.atom_title_prefix') + @page_title)

    @topics = Topic.upcoming.tagged_with(@tag).includes(:sessions)
    updated = @topics.max { |a, b| a.upcoming_sessions[0].updated_at <=> b.upcoming_sessions[0].updated_at } rescue nil
    feed.updated(updated ? updated.upcoming_sessions[0].updated_at : Time.now)

    if @topics.present?
      @topics.sort_by(&:next_time).each do |topic|
        cache(["#{date_slug}/#{sites_key}/tags/show/upcoming/atom", topic], expires_in: 1.day) do
          next unless topic.upcoming_sessions.present?
          feed.entry(topic, updated: topic.next_time, published: topic.next_time) do |entry|
            entry.title(topic.name)
            
            summary = []
            
            topic.upcoming_sessions.first(2).each do |session|
              summary << link_to("#{session_info(session)} - #{session.site.name}", session_url(session, :only_path => false))
            
              # FIXME: add topic description, instructor, location, etc
              #entry.content(session_info(session))
            end
            
            more = topic.upcoming_sessions.size - 2
            summary << link_to("#{more} more upcoming sessions", topic_url(topic, :only_path => false)) if more > 0
            
            entry.summary(summary.join("<br/>\n"), type: 'html')

          end
        end
      end
    else
      # FIXME: should we display anything when there are no upcoming sessions?
    end
  end
end
