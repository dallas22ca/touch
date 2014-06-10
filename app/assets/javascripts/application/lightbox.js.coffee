$(document).on "click", ".close_lightbox", (e) ->
	Lightbox.close $(this).closest(".lightbox")
	false

@Lightbox =
	init: ->
		$(window).resize ->
			$(".lightbox").each ->
				Lightbox.resize $(this)

	close: (lightbox_overlay = false) ->
		lightbox = $(".lightbox:last") unless lightbox
		lightbox.closest(".lightbox_overlay").remove() if lightbox.length
		$("body").removeClass "show_lightbox" unless $(".lightbox").length
		
	open: (content) ->
		lightbox = $("<div class=\"lightbox\">#{content}</div>")
		overlay = $("<div class=\"lightbox_overlay\"></div>")
		lightbox.appendTo overlay
		overlay.appendTo "body"
		$("body").addClass "show_lightbox"
		$(".sub_menu").hide()
		$("#topbar h1 a").removeClass "selected"
		Lightbox.resize lightbox
	
	resize: (lightbox) ->
		lightbox.css "height", "auto"
		extra_for_top_and_bottom = if Touch.mobile then 30 else 100
		height = lightbox.outerHeight()
		height = $(window).height() - extra_for_top_and_bottom  if height > $(window).height() - extra_for_top_and_bottom
		lightbox.css
			"height": "#{height}px"
			"margin-top": "-#{height / 2}px"