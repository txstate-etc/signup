// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Show/Hide the external survey url box if it is enabled
$(function() {
  var textbox = $('div.topic_survey_url');
  textbox.toggle($('#topic_survey_type_2').is(':checked'));

  $('.topic_survey_type input.radio_buttons').change(function(e){
    if ($('#topic_survey_type_2').is(':checked')) {
      textbox.slideDown();
    } else {
      textbox.slideUp();
    }
  });
});
