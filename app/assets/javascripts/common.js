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

// FIXME: this doesn't work because the page changes before the request can complete.
// FIXME: also, what if things are downloaded outside of the browser, like an email or calendar app?

// Generate Google Analytics events for link clicks
$(function() {
  $('a').click(function() {
    if (ga) {
      var linkAddress = $(this).href;
      var linkName = $(this).text;
      var thisPageAddress = window.location;
      var thisPageTitle = document.title;

      ga('send', { 
        'hitType': 'event', 
        'eventCategory': 'Links', 
        'eventAction': thisPageTitle + " <" + thisPageAddress + ">",
        'eventLabel': linkName + " <" + linkAddress + ">" 
      });
    }
  });
});
