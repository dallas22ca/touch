$(document).on "click", ".delete_filter", ->
	$(this).closest("li").remove()
	$("#filter_form").trigger "submit"
	false

$(document).on "click", ".save_this_segment", ->
	url = $(this).attr "href"
	filters = Filters.generate()
	
	if filters.length
		$("#filter_form").find(".saved").hide()
		$("#filter_form").find(".saving").show()
		
		$.post url,
			_method: "patch"
			"segment[filters]": filters
	else
		alert "No filters have been selected."
	false

$(document).on "click", ".add_event_filter", ->
	clone = $(".templates").find(".event_filter_template").clone()
	clone.removeClass "event_filter_template"
	clone.insertBefore "#filters .insert_before"
	false
	
$(document).on "keyup", "#q_form input, #filters input", ->
	$("#filter_form").trigger "submit"

$(document).on "change", "#filters select", ->
	$("#filter_form").trigger "submit"

$(document).on "click", "#filters input[type='checkbox']", ->
	li = $(this).closest("li")

	if $(this).is(":checked")
		li.removeClass "disabled"
	else
		li.addClass "disabled"
		li.find(".field").each ->
			$(this).closest("li").addClass "disabled"
		li.find("input[type='checkbox']").prop "checked", false
	
	$("#filter_form").trigger "submit"

$(document).on "submit", "#filter_form, #q_form", ->
	filters = Filters.generate()
	url = $("#choose_segment").val()
	$("#contacts").find(".loading").show()
	
	if $("#q").val() != ""
		filters.push
			field: "q"
			matcher: "ilike"
			value: $("#q").val()
	
	$.get url,
		filters: filters

	false

@Filters =
	init: ->
		if $("#filter_form").length
			$("#filter_form").trigger "submit"
		
	updateWithSegment: ->
		if $("#choose_segment").length
			split = $("#choose_segment").val().split("=")
			segment_id = split[1] if split.length > 1
			option = $("#choose_segment option:selected")
			segment_name = $.trim option.text()
			Filters.resetFilters()
		
			if segment_id
				filters = $("#filters")
				$(".segment_meta, .save_this_segment").show()
				$(".segment_name").text segment_name
			
				$("#filter_form a[data-href]").each ->
					href = $(this).data "href"
					$(this).attr "href", href.replace("-", segment_id)
			
				for filter in option.data("filters")
					if typeof filter.event == "undefined"
						field = filters.find("input[data-field][value='#{filter.field}']")
						li = field.closest(".disablable")
						li.find("input[data-value]").val filter.value
						disabled = field.closest(".disabled")
						disabled.removeClass "disabled"
						disabled.find("input[type='checkbox']").prop "checked", true
					else
						console.log filter
						clone = $(".templates").find(".event_filter_template").clone()
						clone.removeClass "event_filter_template"
						clone.find("input[type='checkbox']:lt(2)").each ->
							$(this).closest(".disablable").removeClass "disabled"
							$(this).prop "checked", true
					
						clone.find(".disablable").each ->
							unless $(this).find(".disablable").length
								field = $(this).find("input[data-field][value='#{filter.field}']")
								matcher = $(this).find("input[data-matcher][value='#{filter.matcher}']")
								event = $(this).find("input[data-event][value='#{filter.event}']")
							
								if field.length && matcher.length && event.length
									$(this).removeClass "disabled"
									$(this).find("input[type='checkbox']").prop "checked", true
									$(this).find("[data-value]").val filter.value
					
						clone.insertBefore "#filters .insert_before"
			else
				$(".segment_meta, .save_this_segment").hide()
	
	resetFilters: ->
		filters = $("#filters")
		filters.find(".event_filter").remove()
		filters.find(".disablable").addClass "disabled"
		filters.find("input[type='checkbox']").prop "checked", false
		filters.find("[data-value]").val ""
	
	generate: ->
		filters = []
		
		$("#filters").find(".field:visible").each ->
			unless $(this).find(".field:visible").length
				data = {}
				data.field = $(this).find("[data-field]:first").val()
				data.matcher = $(this).find("[data-matcher]:first").val()
				data.value = $(this).find("[data-value]:first").val()
				data.event = $(this).find("[data-event]:first").val() if $(this).find("[data-event]").length
				filters.push data if !$.isEmptyObject(data) && data.value != ""

		filters