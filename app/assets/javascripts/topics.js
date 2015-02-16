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


// Highlight the sidebar link that matches the page we are on, if any.
$(function() {
  if (window.location.pathname == '/') {
    $('#topic-list-link').addClass('selected');
    $('#topic-list-nav a:first').addClass('selected');
  } else {
    var cur_url = window.location.href.split('#')[0];
  
    // special case: highlight "Available Topics" link on any related page:
    // group by department, group by date, month at a glance
    if (new RegExp("/topics($|/alpha|/grid|/by-site|/by-department)").test(cur_url)) {
      $('#topic-list-link').addClass('selected');
    }    
    $('#topic-list-link, div#topic-list-nav a, div.navigation a, div.admin-tools a').each(function() {
      if (this.href == cur_url) {
        $(this).addClass('selected');
      }
    });
    if (cur_url.match('/topics/grid')) {
      $('a[href="/topics/grid"]').addClass('selected');
    }
  }  
});
