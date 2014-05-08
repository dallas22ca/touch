$(document).on "click", ".presence_toggle", ->
	name = false
	index = $(this).index()
	member_id = $(this).closest("tr").find(".row_head").data("member-id")
	member_id = "new" if typeof member_id == "undefined"
	room_id = $("#attendance_header").data("room-id")
	meeting_id = $("#attendance_header").find("th:eq(#{index})").data("id")
	url = $("#attendance_header").data("event-path")
	
	if member_id == "new"
		name = $(".add_on_the_fly .name").text()
		$(this).toggleClass "load"
	else
		$(this).toggleClass "present"
		Attendance.tallyTotals()

	$.post url,
		member_id: member_id
		meeting_id: meeting_id
		room_id: room_id
		present: $(this).hasClass("present")
		name: name

	false

$(document).on "click", "#attendance_header .clear_q", ->
	$("#attendance_header #q").val ""
	$("#attendance tr").show()
	$("#attendance .add_on_the_fly").hide()
	false

$(document).on "keyup", "#attendance_header #q", ->
	q = $(this).val()
	
	if q.length > 0
		$("#attendance_header .clear_q").show()
		$("#attendance .add_on_the_fly").show().find(".name").text(q)
	else
		$("#attendance_header .clear_q").hide()
		$("#attendance .add_on_the_fly").hide().find(".name").text("")
		
	$("#attendance tr:not(.add_on_the_fly):not(:Contains(#{q}))").hide()
	$("#attendance tr:not(.add_on_the_fly):Contains(#{q})").show()

@Attendance =
	uuid: ->
		"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
			r = Math.random() * 16 | 0
			v = (if c is "x" then r else (r & 0x3 | 0x8))
			v.toString 16

	init: ->
		if $("#attendance_footer").length
			Attendance.sort()
			Attendance.tallyTotals()
			Attendance.hideMeetingArrows()
			
	addRow: (data) ->
		data = $.parseJSON(data)
		index = $("#attendance_header tr").find("th[data-id='#{data.meeting_id}']").index()
		
		on_the_fly = $(".add_on_the_fly")
		on_the_fly.find(".load").removeClass "load"
		on_the_fly.find(".name").text ""
		on_the_fly.hide()

		clone = on_the_fly.clone()
		clone.removeClass "add_on_the_fly"
		clone.find(".row_head .pretty_name").text data.pretty_name
		clone.find(".row_head .search").text data.name
		clone.find(".row_head").data("member-id", data.id)
		clone.find("td:eq(#{index})").addClass "present"
		clone.insertAfter "#attendance .add_on_the_fly"
		clone.show()
		
		Attendance.sort()
		Attendance.tallyTotals()
	
	updateRoomCount: (meeting_id, total) ->
		index = $("#attendance_header tr").find("th[data-id='#{meeting_id}']").index()
		total = $("#attendance tr").find("td:eq(#{index}).present").length
		$(this).find("a").text total
	
	hideMeetingArrows: ->
		last_id = $("#attendance_header").data("last-meeting-id")
		first_id = $("#attendance_header").data("first-meeting-id")
		$("#meeting_#{last_id} .next, #meeting_#{first_id} .prev").hide()
	
	removeFirstColumn: ->
		$("#attendance_header tr").find("th:first").remove()
		$("#attendance tr").find("td:first").remove()
		$("#attendance_footer tr").find("td:first").remove()
	
	sort: ->
		$("#attendance tr").order true, (el) ->
			$(".pretty_name", el).text()
		, ->
			$("#attendance tr.add_on_the_fly").prependTo "#attendance tbody"
	
	addEmptyColumn: ->
		toggle_template = $(".presence_toggle_template").html()
		total_template = $(".presence_total_template").html()
		
		$("#attendance td.row_for_new").each ->
			$(toggle_template).insertBefore this
			
		$(total_template).insertBefore $("#attendance_footer td.row_for_new")

	tallyTotals: ->
		$("#attendance_footer tr").find(".total:visible").each ->
			index = $(this).index()
			total = $("#attendance tr").find("td:eq(#{index}).present").length
			$(this).find("a").text total