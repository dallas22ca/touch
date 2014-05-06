jQuery.expr[":"].Contains = jQuery.expr.createPseudo((arg) ->
	(elem) ->
		jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0
)

$(document).on "click", ".presence_toggle", ->
	$(this).toggleClass "present"
	Attendance.tallyTotals()
	false

$(document).on "click", "#attendance_header .clear_q", ->
	$("#attendance_header #q").val ""
	$("#attendance tr").show()
	false

$(document).on "keyup", "#attendance_header #q", ->
	q = $(this).val()
	if q.length > 0 then $("#attendance_header .clear_q").show() else $("#attendance_header .clear_q").hide()
	$("#attendance tr:not(:Contains(#{q}))").hide()
	$("#attendance tr:Contains(#{q})").show()

@Attendance =
	init: ->
		if $("#attendance_footer").length
			Attendance.tallyTotals()

	tallyTotals: ->
		$("#attendance_footer tr").find(".total:visible").each ->
			index = $(this).index()
			total = $("#attendance tr").find("td:eq(#{index}).present").length
			$(this).find("a").text total