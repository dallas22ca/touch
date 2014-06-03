Jibe.events["tasks"] =
	afterCreate: (task, data, scope) ->
		if $.inArray("completed", scope) != -1
			Noterizer.open "Task was added to your list."
			task.remove()
		Tasks.makeEditable()

	afterUpdate: (task, data, scope) ->
		if data.complete_changed
			if data.complete
				if $.inArray("completed", scope) == -1
					if $(".folder_#{data.folder_id}_completed_tasks").length
						task.prependTo ".folder_#{data.folder_id}_completed_tasks"
					else if $(".member_#{data.member_id}_completed_tasks").length
						task.prependTo ".member_#{data.member_id}_completed_tasks"
			else
				if $.inArray("completed", scope) != -1
					if $(".folder_#{data.folder_id}_tasks").length
						task.appendTo(".folder_#{data.folder_id}_tasks")
					else if $(".member_#{data.member_id}_tasks").length
						task.appendTo(".member_#{data.member_id}_tasks")
					$("#tasks").trigger("sortupdate")
				else
					task.remove()
					
		Tasks.makeEditable()
	
	beforeDestroy: (task, data, scope) ->
		Noterizer.open "Task was deleted.", "fail" if $.inArray("completed", scope) != -1

$(document).on "click", ".show_completed_tasks", ->
	$(this).text if $(this).text() == "Show Completed Tasks" then "Hide Completed Tasks" else "Show Completed Tasks"
	$("#completed_tasks").slideToggle 150
	false

$(document).on "paste", ".task p[contenteditable]", (e) ->
	content = (e.originalEvent || e).clipboardData.getData("text/plain") || prompt("Paste something...")
	pasteHtmlAtCaret content
	false

$(document).on "keypress", ".task p[contenteditable]", (e) ->
	code = if e.keyCode then e.keyCode else e.which
	if code == 13
		$(this).trigger "blur"
		false

$(document).on "blur", ".task p[contenteditable]", ->
	task = $(this).closest(".task")
	url = task.data("url")
	content = $(this).text()
	
	if task.data("content") != content
		task.data "content", content

		$.post "#{url}.js",
			_method: "patch"
			task:
				content: content

$(document).on "click", ".task input[type='checkbox']", ->
	if $(this).closest("[data-write]").length
		task = $(this).closest(".task")
		url = task.data("url")

		$.post "#{url}.js",
			_method: "patch"
			task:
				complete: $(this).is(":checked")
	else
		false

$(document).on
	mouseenter: ->
		$(this).find(".meta_links").show() unless Touch.mobile
	mouseleave: ->
		$(this).find(".meta_links").hide()
, "#tasks .task"

@Tasks =
	init: ->
		if $("#tasks").length
			Tasks.makeEditable()
			
			$("#tasks").sortable
				axis: "y"
				items: ".task"
				handle: ".handle"
				placeholder: "ui-state-highlight"
				forcePlaceholderSize: true
				forceHelperSize: true

				helper: (e, ui) ->
					ui.children().each () ->
						$(this).width $(this).width()
					ui

				start: (e, ui) ->
					ui.placeholder.html ""
			
			$("#tasks").bind "sortupdate", ->
				url = $("#tasks").data("url")
				$.post url, $(this).sortable("serialize")
	
	makeEditable: ->
		$("#tasks[data-write]").find(".task:not(.complete)").find(".content").attr "contenteditable", true
		$("#tasks").css "min-height", "auto"
		$("#tasks").css "min-height", $("#tasks").height()