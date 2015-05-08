module SurveyResponsesHelper

  SURVEY_COMMENT_TYPES = { most_useful: 'What Attendees Found Most Useful', general: 'General Comments'}

  def survey_comments(method, model_object, limit=nil)
    return '' unless SURVEY_COMMENT_TYPES.key? method
    
    comments = model_object.survey_responses.map(&method).reject(&:blank?)
    comments = comments.first(limit) if limit
    
    comment_list(SURVEY_COMMENT_TYPES[method], comments)
  end

  def comment_list(title, comments)
    return '' if comments.blank?
    
    ret = '<div class="survey-comments">'
    ret << "<h2>#{title}</h2>"
    ret << '<ul>'
    comments.each { |comment| ret << "<li>#{strip_tags comment}</li>" }
    ret << '</ul>'
    ret << '</div>'
    ret.html_safe
  end

  def link_to_comments(controller, model_object, which)
    link_to "all comments ⟫", {
      controller: controller, 
      action: "survey_comments", 
      id: model_object, 
      which: which },
      class: 'survey-comments-link'
  end

  def rating_radios(label)
    {
      label: label,
      as: :radio_buttons, 
      collection: [
        ['4 - Excellent', 4], 
        ['3 - Good',      3], 
        ['2 - Fair',      2],
        ['1 - Poor',      1]
      ]
    }
  end
end
