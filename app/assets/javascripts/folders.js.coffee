$(document).on "click", ".choose_folder", ->
	$(this).closest("li").toggleClass "open"
	$(".mobile_folders_list").toggle()
	$(this).closest("ul").find("a.selected:not(.choose_folder)").removeClass "selected"
	$(this).toggleClass "selected"
	false

$(document).on "click", "#folder_sidebar .open a", ->
	$(this).closest(".open").removeClass "open"

$(document).on "click", "#folder_sidebar .start_transition", ->
	$("#folder_sidebar .start_transition.selected").removeClass "selected"
	$(this).addClass "selected"