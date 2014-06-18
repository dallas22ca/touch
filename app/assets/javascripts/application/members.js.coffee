Jibe.events["members"] =
	afterCreate: (member, data, scope) ->
		if $("#members").length
			member.appendTo "#members"
		else if $(".add_on_the_fly").length
			member.remove()
			json =
				name: data.name
				pretty_name: data.pretty_name
				id: data.id
			Attendance.addRow JSON.stringify(json)
		Noterizer.open "#{data.name} was added." if data.bulk_action != true
	afterUpdate: (member, data, scope) ->
		if !Jibe.inScope "room_id=#{data.id}", scope
			$("tr[data-member-id='#{data.id}'] .row_head").find(".pretty_name").text data.pretty_name
			$("tr[data-member-id='#{data.id}'] .row_head").find(".search").text data.name
		Noterizer.open "#{data.name} was updated." if data.bulk_action != true
	afterDestroy: (member, data, scope) ->
		Noterizer.open "#{data.name} was deleted.", "fail" if data.bulk_action != true

$(document).on "click", ".remove_member_field", ->
	$(this).closest("tr").remove()
	false

$(document).on "click", ".add_member_field", ->
	template = $(".new_member_fields .templates").clone()
	template.removeClass "templates"
	template.find(".value_field").attr "name", "member[data][]"
	$(".new_member_fields tbody").append template
	false

$(document).on "blur", "#new_member input, .edit_member input", ->
	Member.prepDataFields()

@Member =
	prepDataFields: ->
		$(".new_member_fields .key_field").each ->
			key = $(this).val().toLowerCase().replace(" ", "_")
			if key != ""
				$(this).closest("tr").find(".value_field").attr "name", "member[data][#{key}]"
			else
				$(this).closest("tr").find(".value_field").attr "name", ""
