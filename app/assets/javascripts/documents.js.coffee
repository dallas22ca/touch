$(document).on
	mouseenter: ->
		$(this).find(".delete").css "visibility", "visible"
	mouseleave: ->
		$(this).find(".delete").css "visibility", "hidden"
, "[data-delete] tr, [data-delete] li"

$(document).on "change", "#document_file", ->
	$(this).closest("form").trigger "submit"

$(document).on "click", ".upload_document", ->
	$("#document_file").trigger "click"
	false