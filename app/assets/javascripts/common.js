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
