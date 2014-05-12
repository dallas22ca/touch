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
	task = $(this).closest(".task")
	url = task.data("url")

	$.post "#{url}.js",
		_method: "patch"
		task:
			complete: $(this).is(":checked")

@Tasks =
	init: ->
		$("#tasks").sortable
			items: ".task"
			handle: ".handle"
			placeholder: "ui-state-highlight"
			forcePlaceholderSize: true
			forceHelperSize: true

			helper: (e, ui) ->
				ui.children().each () ->
					$(this).width $(this).width()
				ui
			
			update: ->
				url = $("#tasks").data("url")
				$.post url, $(this).sortable("serialize")

			start: (e, ui) ->
				ui.placeholder.html ""