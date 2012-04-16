class ScaleRatings < ActiveRecord::Migration
  def self.up
    # for each survey_response, scale the ratings from 1-5 to 1-4
    # make 4s = 3 and make 5s = 4. Don't change 1s ,2s, or 3s
    SurveyResponse.all.each do |s|
      s.class_rating -= 1 if s.class_rating > 3
      s.instructor_rating -= 1 if s.instructor_rating > 3
      s.save(false)
    end
  end

  def self.down
    # for each survey_response, scale the ratings from 1-4 to 1-5
    # make 4s = 5. Make 1/2 of the 3s = 4, since we only changed some of them in the up migration
    # So, WARNING: this down method doesn't exactly recreate the previous state.
    SurveyResponse.all.each do |s|
      s.class_rating = 5 if s.class_rating == 4
      s.class_rating = 4 if s.class_rating == 3 && s.id % 2 == 0
      s.instructor_rating = 5 if s.instructor_rating == 4
      s.instructor_rating = 4 if s.instructor_rating == 3 && s.id % 2 == 0
      s.save(false)
    end
  end
end
