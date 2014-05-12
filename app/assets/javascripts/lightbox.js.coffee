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
			extra_for_top_and_bottom = if Touch.mobile then 30 else 100
			height = $("#lightbox").outerHeight()
			height = $(window).height() - extra_for_top_and_bottom  if height > $(window).height() - extra_for_top_and_bottom
			$("#lightbox").css
				"height": "#{height}px"
				"margin-top": "-#{height / 2}px"