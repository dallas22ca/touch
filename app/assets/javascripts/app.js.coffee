@Jibe ||= { events: {} }

$(document).on "click", "#topbar .nav a", ->
	$("#topbar .nav a").removeClass "selected"
	$(this).addClass "selected"
	
$(document).on "click", ".show_sub_menu", ->
	$(".sub_menu").toggle()
	$(this).toggleClass  "selected"
	if Touch.mobile
		$(".nav").hide()
		$(".show_nav").removeClass "selected"
	false

$(document).on "click", ".show_nav", ->
	$(this).toggleClass "selected"
	$(".nav").toggle()
	if Touch.mobile
		$(".sub_menu").hide()
		$("#topbar h1 a").removeClass "selected"
	false

@Touch =
	mobile: false

	mobileCheck: ->
		Touch.mobile = $(window).width() < 720

@unload = ->
	$(".loading").show()

load = ->
	$(".loading").hide()
	Touch.mobileCheck()
	
	Attendance.init()
	Event.init()
	Segments.init()
	Filters.init()
	Tasks.init()
	Comments.init()

$ ->
	Lightbox.init()
	$(window).resize Touch.mobileCheck

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load