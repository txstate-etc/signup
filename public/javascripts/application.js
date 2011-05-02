// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).up().insert({
    before: content.replace(regexp, new_id)
  });
}