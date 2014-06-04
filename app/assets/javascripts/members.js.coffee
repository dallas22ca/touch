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