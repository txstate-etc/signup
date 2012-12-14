// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function expand_list(link) {
  Effect.BlindDown($(link).up().previous());
  $(link).up().next().style.display = 'block';
  $(link).up().style.display = 'none';
}

function collapse_list(link) {
  Effect.BlindUp($(link).up().previous(1));
  $(link).up().style.display = 'none';
  $(link).up().previous().style.display = 'block';
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

function after_update_instructor(element, value) {
  if (value.hasClassName('add-new')) {
    element.value = ""; 

    // trigger modal ajax form for adding new user
    show_instructor_dialog(element);
  }
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

// Highlight the sidebar link that matches the page we are on, if any.
Event.observe(document, 'dom:loaded', function () {
  var cur_url = window.location.href.split("#")[0];
  
  // special case: highlight "Available Topics" link on any related page:
  // group by department, group by date, month at a glance
  if (['/topics$', '/topics/upcoming', '/topics/grid', '/topics/by-department'].any(function(s) { return cur_url.match(s); })) {
    $('topic-list-link').addClassName('selected');
    $('topic-list-nav').select('a').each(function(link) {
      if (link.href == cur_url) {
        link.addClassName('selected');
      }
    });
  } else {
    $$('div.navigation a', 'div.admin-tools a').each(function(link) {
      if (link.href == cur_url) {
        link.addClassName('selected');
      }
    });
  }
  
});
