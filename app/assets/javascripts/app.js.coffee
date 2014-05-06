$(document).on "click", ".show_sub_menu", ->
	$(".sub_menu").toggle()
	$(this).toggleClass  "selected"
	false

@unload = ->
	$(".loading").show()

load = ->
	$(".loading").hide()
	Attendance.init()
	Event.init()

$ ->
	Lightbox.init()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load