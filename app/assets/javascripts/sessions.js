// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function revealRegPeriodArea() {
  $('#registration-period-field').slideDown();
  var start = $('#session_reg_start');
  start.val(start.attr('data-default'));
  var end = $('#session_reg_end');
  end.val(end.attr('data-default'));
}

function hideRegPeriodArea() {
  $('#registration-period-field').slideUp();
  $('#registration-period-field .datetimepicker').val('');
}

var dateFormat = 'MM d, yy';
var timeFormat = 'h:mm TT';

var tryParse = function(dateText) {
  try {
      return $.datepicker.parseDateTime( dateFormat, timeFormat, dateText, null, {'timeFormat':timeFormat} );
    } catch(err) {
      return false;
    }
}

var validateDate = function validateDate(el, dateText) {
  if (!tryParse(dateText)) {
    $(el).val("")
    $(el).datetimepicker('setDate', null)
  }
}

function addDatePicker(input, setTime) {
  var value = new Date();
  value.setHours(12, 0, 0, 0);
  value = value.getTime();
  value = new Date(value + 86400000);

  $(input).datetimepicker({
    dateFormat: dateFormat,
    timeFormat: timeFormat,
    hourText: 'Time: ',
    onClose: function(dateText, picker) {
      validateDate(this, dateText);
    },
    showTime: false,
    stepMinute: 5,
    minDate: '+0D',
    defaultDate: +1,
    hour: 12,
    minute: 0
  });
  
  if(setTime && !input.value) {
    $(input).datetimepicker('setDate', getNextDateTime('#occurrences'));
  }
} 

function getNextDateTime(root) {
  // Set the initial value of a new occurrence field to the same
  // time as the previous (non-deleted) field, but on the next day.
  var value;
  var fields = $(root + ' .datetimepicker:visible');

  for (i = fields.length - 1; i >= 0; i--) {
    var text = fields[i].value;
    if (text) {
      var timestamp = Date.parse(text);
      if (isNaN(timestamp) == false && timestamp > 0) {
        value = timestamp;
        break;
      }
    }
  }
  
  if (!value) {
    value = new Date();
    value.setHours(12, 0, 0, 0);
    value = value.getTime();
  }

  return new Date(value + 86400000);
}

$(function() {
  addDatePicker($('.datetimepicker'));
  $('#occurrences').on('cocoon:after-insert', function(e, insertedItem) {
    var input = insertedItem.find('.datetimepicker');
    addDatePicker(input, true);
  });

  $('#instructors, #permissions').on('railsAutocomplete.select', 'input.autocomplete', function(event, data) {
    if (data.item.id == 'add-new') {
      // display modal
      new NewUserDialog($('#user-modal'), event.target).show();
    }
    
  });

  $('#cancel-session-link').on('click', function cancelClick(event, data) {
    new CancelDialog($('#cancel-session-dialog')).show();
  });

  $('#email-dialog-link').on('click', function emailAllClick(event, data) {
    new EmailAllDialog($('#email-dialog')).show();
  });

  $('#new_session,#edit_session').on('submit', function validate(event, data) {
    $('.datetimepicker').each(function(idx,el) {
      validateDate(el, $(el).val());
    });
  });
});
