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
      //FIXME: hide errors 
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
    // FIXME: display model errors
    alert("Error: " + error);
    dialog.dialog('close');
  });

  dialog.find('#cancel-link').on('click', function(event) {
    event.preventDefault();
    dialog.dialog('close');
  });

  this.show = function show(argument) {
    dialog.dialog("open");
  };


};
