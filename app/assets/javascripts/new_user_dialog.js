function NewUserDialog(content, input) {
  var success = false;
  var dialog = $(content).dialog({
    autoOpen: false,
    height: 500,
    width: 500,
    modal: true,
    close: function() {
      form[ 0 ].reset();
      if (!success) {
        input.value = input.defaultValue;
      }
      $('#error-wrap').html('');
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
    var errors = $.parseJSON(xhr.responseText);
    var html = '<div id="error_explanation">';
    html += '<h2>This instructor can\'t be saved.</h2>';
    html += '<p>There were problems with the following fields:</p>';
    html += '<ul>';
    
    if (errors.last_name) {
      html += "<li>Last name " + errors.last_name[0] + ".</li>";
    }
    if (errors.email) {
      html += "<li>Email " + errors.email[0] + ".</li>";
    }

    if (errors.login && errors.login[0] == 'has already been taken') {
      html += "<li>Instructor already exists.</li>";
    }

    html += "</ul></div>";
    
    $('#error-wrap').html(html);
    
  });

  dialog.find('#cancel-link').on('click', function(event) {
    event.preventDefault();
    dialog.dialog('close');
  });

  this.show = function show(argument) {
    dialog.dialog("open");
  };


};
