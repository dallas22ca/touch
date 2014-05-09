$(document).on "change", "#choose_segment", ->
	Filters.updateWithSegment()
	$("#filter_form").trigger "submit"

@Segments =
	init: ->
		Filters.updateWithSegment()
		
	addToLightbox: ->
		filters = Filters.generate()
		
		for filter in filters
			wrapper = $("<div>").addClass "filter"
			
			field = $("<input>").attr("name", "segment[filters][][field]").attr("type", "hidden").val filter.field
			matcher = $("<input>").attr("name", "segment[filters][][matcher]").attr("type", "hidden").val filter.matcher
			value = $("<input>").attr("name", "segment[filters][][value]").attr("type", "hidden").val filter.value
			event = $("<input>").attr("name", "segment[filters][][event]").attr("type", "hidden").val filter.event unless typeof filter.event == "undefined"
			
			field.appendTo wrapper
			matcher.appendTo wrapper
			value.appendTo wrapper
			event.appendTo wrapper unless typeof event == "undefined"
			
			wrapper.appendTo "#lightbox .hidden_filters"