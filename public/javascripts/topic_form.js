document.observe ('dom:loaded', function() {
	if ( $F('topic_survey_type_2') == '2' ) {
		$('survey-external').show();
	} else {
		$('survey-external').hide();		
	}
	
	$('topic_survey_type_2').observe( 'click', function() {
		Effect.BlindDown('survey-external', { duration: 0.5, queue: 'end' } );
	})
	$('topic_survey_type_1').observe( 'click', function() {
		Effect.BlindUp('survey-external', { duration: 0.5, queue: 'end' } );
	})
	$('topic_survey_type_0').observe( 'click', function() {
		Effect.BlindUp('survey-external', { duration: 0.5, queue: 'end' } );
	})
});