// Toggle expand/collapse of long lists
$(function() {
  $('a.list-expand').click(function(e){
    e.preventDefault();
    $(this).prev('ul').slideToggle();
    $(this).hasClass('collapsed') ? $(this).text('show fewer ▲') : $(this).text('show more ▼');
    $(this).toggleClass('collapsed');
  });
});
