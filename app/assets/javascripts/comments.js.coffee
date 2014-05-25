$(document).on "keypress", "#comment_body", (e) ->
	code = if e.keyCode then e.keyCode else e.which
	if code == 13
		$(this).closest("form").trigger "submit"
		false

Jibe.events["comments"] =
	beforeCreate: (comment, data) ->
		comment.hide()
		
	afterCreate: (comment, data) ->
		$(".no_comments").remove()
		Comments.init()
		comment.fadeIn()

	afterDestroy: (comment, data) ->
		comment.remove()

@Comments =
	init: ->
		if $(".comments").length
			setTimeout ->
				$(window).scrollTop $(document).outerHeight()
			, 1