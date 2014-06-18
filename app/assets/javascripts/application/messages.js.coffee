$(document).on "change", "#message_via", ->
	if $(this).val() == "sms"
		$(".subject_field").hide()
		$(".sms_limit").show()
		$("#message_body").css "height", "5em"
	else
		$(".subject_field").show()
		$(".sms_limit").hide()
		$("#message_body").css "height", ""

$(document).on "keyup", "#message_body", ->
	limit = 160
	length = $(this).val().length
	
	if length > limit
		length = 160
		$(this).val $(this).val().substring(0, 159)
	
	$(".sms_length").text length