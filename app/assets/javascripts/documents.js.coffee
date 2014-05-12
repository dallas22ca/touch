$(document).on "change", "#document_file", ->
	$(this).closest("form").trigger "submit"