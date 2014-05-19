$(document).on "click", "#folder_sidebar .start_transition", ->
	$("#folder_sidebar .start_transition.selected").removeClass "selected"
	$(this).addClass "selected"