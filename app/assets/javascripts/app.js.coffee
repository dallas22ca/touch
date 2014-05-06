@unload = ->
	$(".loading").show()

load = ->
	$(".loading").hide()
	Attendance.init()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load