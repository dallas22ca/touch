$(document).on "click", ".toggle_signin_method", ->
	method = $(".signin_method:not(:visible)")
	$(".signin_method:visible").hide 0, ->
		method.fadeIn 150
		method.find("input:visible:first").trigger "focus"
	false