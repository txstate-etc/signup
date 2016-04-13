// Toggle expand/collapse of long lists
$(function() {
  $('a.list-expand').click(function(e){
    e.preventDefault();
    $(this).prev('ul').slideToggle();
    $(this).hasClass('collapsed') ? $(this).text('show fewer ▲') : $(this).text('show more ▼');
    $(this).toggleClass('collapsed');
  });
});

// Highlight element in given color for given duration.
jQuery.fn.flash = function() {
  var el = this;
  el.addClass("flash");
  setTimeout( function(){
      el.removeClass("flash");
    }, 1000); // Timeout must be the same length as the 
              // CSS3 transition or longer (or you'll mess up the transition)
}

// Prevent double submission of forms
// http://technoesis.net/prevent-double-form-submission-using-jquery/
jQuery.fn.preventDoubleSubmission = function() {
  $(this).on('submit',function(e){
    var $form = $(this);
 
    if ($form.data('submitted') === true) {
      // Previously submitted - don't submit again
      e.preventDefault();
    } else {
      // Mark it so that the next submit can be ignored
      $form.data('submitted', true);
    }
  });
 
  // Keep chainability
  return this;
};

$(function() {
  $('[data-prevent-double-submit]').preventDoubleSubmission();
});


// FIXME: this doesn't work because the page changes before the request can complete.
// FIXME: also, what if things are downloaded outside of the browser, like an email or calendar app?

// Generate Google Analytics events for link clicks
$(function() {
  $('a').click(function() {
    if (typeof ga !== 'undefined') {
      var linkAddress = $(this).href;
      var linkName = $(this).text;
      var thisPageAddress = window.location;
      var thisPageTitle = document.title;

      ga('send', { 
        'hitType': 'event', 
        'eventCategory': 'Links', 
        'eventAction': thisPageTitle + " <" + thisPageAddress + ">",
        'eventLabel': linkName + " <" + linkAddress + ">",
        'transport': 'beacon'
      });
    }
  });
});
