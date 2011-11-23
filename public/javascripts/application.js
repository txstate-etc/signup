// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function expand_session_list(link) {
  Effect.BlindDown($(link).up().previous());
  $(link).up().next().style.display = 'inline';
  $(link).up().style.display = 'none';
}

function collapse_session_list(link) {
  Effect.BlindUp($(link).up().previous(1));
  $(link).up().style.display = 'none';
  $(link).up().previous().style.display = 'inline';
}

function revealAccommodationsArea() {
	Effect.BlindDown('special-accommodations-field', { duration: 0.5 } );
}

function hideAccommodationsArea() {
	Effect.BlindUp('special-accommodations-field', { duration: 0.5 } );
	$$('#special-accommodations-field textarea')[0].value = ""
}

function revealRegPeriodArea() {
  Effect.BlindDown('registration-period-field', { duration: 0.5 } );
}

function hideRegPeriodArea() {
  Effect.BlindUp('registration-period-field', { duration: 0.5 } );
  $$('#registration-period-field input')[0].value = ""
  $$('#registration-period-field input')[1].value = ""
}

function remove_fields(link) {
  $(link).previous("input[type=hidden]").value = "1";
  $(link).up(".fields").hide();
}

function add_fields(link, association, content, init_func) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  
  $(link).up().insert({
    before: content.replace(regexp, new_id)
  });
  
  if(window[init_func]) window[init_func](link);
}    

function set_initial_occurrence_value(link) {
  // Set the initial value of a new occurrence field to the same
  // time as the previous (non-deleted) field, but on the next day.
  var value;
  var fields = $(link).up(1).select('.fields').filter(function(el) { return el.visible(); }).reverse();

  for(i=0;i<fields.length;i++) {
    var text = fields[i].select('input[type=text]')[0].value;
    if(text) {
      var timestamp=Date.parse(text);
      if (isNaN(timestamp)==false && timestamp > 0) {
        value = timestamp;
        break;
      }
    }
  }
  
  if(value) {
    value = new Date(value + 86400000).toFormattedString(true);
  } else {
    value = '';
  }
  
  $(link).up().previous('.fields').select('input[type=text]')[0].value = value;
}