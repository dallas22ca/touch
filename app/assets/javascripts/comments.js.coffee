$(document).on "keypress", "#comment_body", (e) ->
	code = if e.keyCode then e.keyCode else e.which
	if code == 13
		$(this).closest("form").trigger "submit"
		false

@Comments =
	init: ->
		if $(".comments").length
			setTimeout ->
				$(window).scrollTop $(document).outerHeight()
			, 1