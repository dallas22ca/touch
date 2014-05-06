$(document).on "click", "#lightbox_overlay, .close_lightbox", ->
	Lightbox.close()
	false

@Lightbox =
	init: ->
		$(window).resize Lightbox.resize

	close: ->
		$("body").removeClass "show_lightbox"
		
	open: ->
		$("body").addClass "show_lightbox"
		$(".sub_menu").hide()
		$("#topbar h1 a").removeClass "selected"
		Lightbox.resize()
	
	resize: ->
		if $("#lightbox:visible").length
			$("#lightbox").css "height", "auto"
			height = $("#lightbox").outerHeight()
			height = $(window).height() - 30 if height > $(window).height() - 30
			$("#lightbox").css
				"height": "#{height}px"
				"margin-top": "-#{height / 2}px"