$(document).on "click", ".delete_filter", ->
	$(this).closest("li").remove()
	false

$(document).on "click", ".add_event_filter", ->
	clone = $(".templates").find(".event_filter_template").clone()
	clone.removeClass "event_filter_template"
	clone.insertBefore "#filters .insert_before"
	false
	
$(document).on "keyup", "#q_form input, #filters input", ->
	$(this).closest("form").trigger "submit"

$(document).on "click", "#filters input[type='checkbox']", ->
	li = $(this).closest("li")

	if $(this).is(":checked")
		li.removeClass "disabled"
	else
		li.addClass "disabled"
		li.find(".field").each ->
			$(this).closest("li").addClass "disabled"
		li.find("input[type='checkbox']").prop "checked", false
	
	$(this).closest("form").trigger "submit"

$(document).on "submit", "#filter_form, #q_form", ->
	filters = []
	url = $(this).attr("action")
	$("#contacts").find(".loading").show()
	
	if $("#q").val() != ""
		data =
			field: "q"
			matcher: "ilike"
			value: $("#q").val()
		filters.push data
	
	$("#filters").find(".field:visible").each ->
		unless $(this).find(".field:visible").length
			data = {}
			data.field = $(this).find("[data-field]:first").val()
			data.matcher = $(this).find("[data-matcher]:first").val()
			data.value = $(this).find("[data-value]:first").val()
			data.event = $(this).find("[data-event]:first").val() if $(this).find("[data-event]").length
			filters.push data if !$.isEmptyObject(data) && data.value != ""
	
	$.get url,
		filters: filters

	false

@Filters =
	init: ->
		false
	
	