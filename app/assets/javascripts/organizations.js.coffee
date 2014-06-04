Jibe.events["organizations"] =
	afterUpdate: (org, data, scope) ->
		if data.importing_changed
			if data.importing
				Noterizer.open data.import_progress, "success", true
			else
				if "#{data.import_progress}".indexOf("re-upload") == -1
					Noterizer.open data.import_progress, "success", false
				else
					Noterizer.open data.import_progress, "fail", true

$(document).on "click", "#organizations .moduler a", ->
	$(this).html " "
	$(this).closest("td").addClass "load"
	
$(document).on "click", ".show_import_fields", ->
	$(".import_fields").show()
	$(this).hide()
	$("#new_member").hide()
	Lightbox.resize $(this).closest(".lightbox")
	false

$(document).on "change", "#organization_members_import", ->
	ext = $(this).val().split(".")[1]
	if $.inArray(ext, ["csv"]) == -1
		$(this).val ""
		alert "This is not a valid file type. Only .csv files are permitted."
	else
		$(".contact_error").fadeIn()
		Lightbox.resize $(this).closest(".lightbox")

$(document).on "submit", ".import_fields", ->
	Lightbox.close()
	Noterizer.open "Your file is uploading...", "success", true