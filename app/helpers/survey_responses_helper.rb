module SurveyResponsesHelper
  
  def usefulness_comments(model_object)
    comments = model_object.survey_responses.inject([]) do |list, response| 
      next list if response.most_useful.blank?
      break list if list.count >= 20 
      list << response.most_useful
    end
    
    if comments.size > 0
      ret = '<div class="survey-comments">'
      ret << '<h2>What Attendees Found Most Useful</h2>'		
      ret << expandible_list(comments)
      ret << '</div>'
    else
      ''
    end
  end

  def overall_comments(model_object)
    comments = model_object.survey_responses.inject([]) do |list, response| 
      next list if response.comments.blank?
      break list if list.count >= 20 
      list << response.comments
    end
    
    if comments.size > 0
      ret = '<div class="survey-comments">'
      ret << '<h2>General Comments</h2>'
      ret << expandible_list(comments)
      ret << '</div>'
    else
      ''
    end
  end
  
end
