$(document).on "click", "#organizations .moduler a", ->
	$(this).html " "
	$(this).closest("td").addClass "load"