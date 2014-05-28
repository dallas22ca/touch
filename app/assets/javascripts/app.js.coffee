$(document).on "click", ".show_new_password_fields", ->
	$(".new_password_fields").toggle()
	$(this).hide()
	false

$(document).on "submit", "form", ->
	$(this).trigger "touch:disable"

$(document).on "touch:disable", "form", ->
	button = $(this).find("button[type='submit'], input[type='submit']")
	button.attr "disabled", true
	button.find(".disabled").show()
	button.find(".enabled").hide()

$(document).on "touch:enable", "form", ->
	button = $(this).find("button[type='submit'], input[type='submit']")
	button.removeAttr "disabled"
	button.find(".enabled").show()
	button.find(".disabled").hide()

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
	Homes.init()

$ ->
	Lightbox.init()
	$(window).resize Touch.mobileCheck

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load