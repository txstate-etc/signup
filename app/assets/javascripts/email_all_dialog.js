function EmailAllDialog(content) {
  var dialog = $(content).dialog({
    autoOpen: false,
    height: 'auto',
    width: 'auto',
    modal: true,
    close: function() {
      form[ 0 ].reset();
    },
    open: function() {
      jQuery('.ui-widget-overlay').on('click', function(){
        dialog.dialog('close');
      })
    }
  });

  var form = dialog.find( "form" ).on('submit', function(event) {
    if (!$('#message_text').val()) {
      alert('The email message may not be blank');
      this.reset();
      return false;
    }
    return true;
  });

  dialog.find('.hide-dialog-link').on('click', function(event) {
    event.preventDefault();
    dialog.dialog('close');
  });

  this.show = function show(argument) {
    dialog.dialog("open");
  };
};
