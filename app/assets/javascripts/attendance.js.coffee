jQuery.expr[":"].Contains = jQuery.expr.createPseudo((arg) ->
	(elem) ->
		jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0
)

$(document).on "click", ".presence_toggle", ->
	index = $(this).index()
	membership_id = $(this).closest("tr").find(".row_head").data("membership-id")
	room_id = $("#attendance_header").data("room-id")
	meeting_id = $("#attendance_header").find("th:eq(#{index})").data("id")
	url = $("#attendance_header").data("event-path")
	$(this).toggleClass "present"
	Attendance.tallyTotals()
	
	$.post url,
		membership_id: membership_id
		meeting_id: meeting_id
		room_id: room_id
		present: $(this).hasClass("present")

	false

$(document).on "click", "#attendance_header .clear_q", ->
	$("#attendance_header #q").val ""
	$("#attendance tr").show()
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
	init: ->
		if $("#attendance_footer").length
			Attendance.tallyTotals()
			Attendance.hideLatestMeetingArrow()
		
	hideLatestMeetingArrow: ->
		id = $("#attendance_header").data("last-meeting-id")
		$("#meeting_#{id} .next").hide()
	
	removeFirstColumn: ->
		$("#attendance_header tr").find("th:first").remove()
		$("#attendance tr").find("td:first").remove()
		$("#attendance_footer tr").find("td:first").remove()
	
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