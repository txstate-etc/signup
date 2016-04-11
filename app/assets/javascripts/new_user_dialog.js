function NewUserDialog(content, input) {
  var success = false;
  var dialog = $(content).dialog({
    autoOpen: false,
    height: 580,
    width: 500,
    modal: true,
    close: function() {
      form[ 0 ].reset();
      if (!success) {
        input.value = input.defaultValue;
      }
      $('#error-wrap').html('');
      clear_invalid();
    },
    open: function() {
      jQuery('.ui-widget-overlay').on('click', function(){
        dialog.dialog('close');
      })
    }
  });

  var form = dialog.find( "form" ).on('ajax:success', function(event, data, status, xhr) {
    var user = $.parseJSON(xhr.responseText);
    $(input).val(user.name_and_login).flash();
    success = true;
    dialog.dialog('close');
  }).on('ajax:error', function(event, xhr, status, error) {
    // FIXME: there's probably a better way to do this
    //{"last_name":["can't be blank"],"email":["can't be blank"],"login":["can't be blank"]}
    var r = $.parseJSON(xhr.responseText);
    
    var html = '<div id="error_explanation">';
    html += '<h2>This instructor can\'t be saved.</h2>';
    html += '<p>There were problems with the following fields:</p>';
    html += '<ul>';
    
    clear_invalid();

    if (r.errors.login) {
      if (r.errors.login[0] == 'has already been taken') {
        html += "<li>Instructor already exists.</li>";
      } else {
        html += "<li>" + r.errors.login[0] + "</li>";
      }
      mark_invalid('user_login');
    } 

    if (r.errors.last_name) {
      html += "<li>Last name " + r.errors.last_name[0] + ".</li>";
      mark_invalid('user_last_name');
    }

    if (r.errors.email) {
      html += "<li>Email " + r.errors.email[0] + ".</li>";
      mark_invalid('user_email');
    }

    html += "</ul></div>";

    if (r.duplicate) {
      html +='<div id="duplicate-user">';
      html += '<h3>Did you mean '+ r.duplicate +'?</h3>';
      html += '<a id="add-duplicate" data-duplicate="'+ r.duplicate +'" href="#">';
      html += 'Add existing user ' + r.duplicate + ' as an instructor.';
      html += '</a></div>';
    }
    
    $('#error-wrap').html(html);
    
  });

  dialog.find('#cancel-link').on('click', function(event) {
    event.preventDefault();
    dialog.dialog('close');
  });

  dialog.on('click', function(event) {
    if (event.target.id == "add-duplicate") {
      event.preventDefault();
      $(input).val($(event.target).data('duplicate')).flash();
      success = true;
      dialog.dialog('close');
    }
  });

  this.show = function show(argument) {
    dialog.dialog("open");
  };

  var mark_invalid = function mark_invalid(field) {
    form.find('div.'+field).addClass('field_with_errors');
  }

  var clear_invalid = function clear_invalid() {
    form.find('div.field_with_errors').removeClass('field_with_errors');
  }

};
