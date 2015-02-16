$(function () {
  
  $('p.special-accommodations').on('click', function() {
    if ($(this).hasClass('collapsed')) {
      $(this).removeClass('collapsed');
    } else {
      $(this).addClass('collapsed');
    }
    $(this).flash();
  });

  $('.radio-all-wrap input').on('change', function() {
    if ($(this).is(':checked')) {
      $('.attendance-radios input[value='+$(this).val()+']').prop('checked', true);
    }
  });
});
