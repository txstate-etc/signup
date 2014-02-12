Event.observe(document, 'dom:loaded', function () {
	
	$$('p.special-accommodations').each( function (item) {
		item.observe('click', function(event) {
			if (this.hasClassName('collapsed')) {
				this.removeClassName('collapsed');
			} else {
				this.addClassName('collapsed');
			}
			new Effect.Highlight(this, { startcolor: '#a56769', endcolor: '#ffffff', restorecolor: 'transparent' });
		});
	});

	$$('.radio-all-wrap input').each( function (item) {
		item.observe('change', function(event) {
			$$('.attendance-radios input').each( function (radio) {
				if (radio.value == item.value) {
					radio.checked = true;					
				}
			});
		});
	});
});
