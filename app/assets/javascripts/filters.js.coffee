$(document).on "click", ".add_event_filter", ->
	clone = $(".templates").find(".event_filter_template").clone()
	clone.insertBefore "#filters .insert_before"
	false

@Filters =
	init: ->
		false
	
	