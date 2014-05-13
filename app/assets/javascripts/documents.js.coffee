$(document).on
	mouseenter: ->
		$(this).find(".delete").css "visibility", "visible"
	mouseleave: ->
		$(this).find(".delete").css "visibility", "hidden"
, "#documents .document"

$(document).on "change", "#document_file", ->
	$(this).closest("form").trigger "submit"

$(document).on "click", ".upload_document", ->
	$("#document_file").trigger "click"
	false