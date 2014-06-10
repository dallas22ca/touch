$(document).on "click", ".member_checkbox", ->
	ids = []
	
	$(".member_checkbox:checked").each ->
		ids.push $(this).val()
		
	if ids.length
		url = $(".add_to_sequence").data "url"
		$(".add_to_sequence").attr "href", "#{url}?member_ids[]=#{ids.join("&member_ids[]=")}"
		$(".add_to_sequence").show()
	else
		$(".add_to_sequence").hide()