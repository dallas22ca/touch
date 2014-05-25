@Jibe ||= {}

Jibe.tearDown = ->
	Jibe.initialized = false
	Jibe.pusher.disconnect()
	
Jibe.initialized = false

Jibe.init = ->
	unless Jibe.initialized
		Jibe.initialized = true
		pusher_key = $("meta[name='pusher-key']").attr("content")
		Jibe.pusher = new Pusher pusher_key
		channel = Jibe.pusher.subscribe "Jibe"
		
		channel.bind "event", (data) ->
			$("script[type='x-jibe'][data-resource='#{data.collection}']").each ->
				scope = $(this).data("scope")
				wrapper = $(this).parent()
				before_hook_name = "before#{data.action_capitalized}"
				after_hook_name = "after#{data.action_capitalized}"
				partial = $(data.partial)
				on_page = $(".#{data.dom_id}, ##{data.dom_id}, .#{data.model}[data-id='#{data.id}']")
				has_events = typeof Jibe.events[data.collection] != "undefined"
				
				if has_events && typeof Jibe.events[data.collection][before_hook_name] == "function"
					Jibe.events[data.collection][before_hook_name].call null, partial, data.data, scope

				if data.action_name == "create"
					if $(this).data("strategy") == "prepend"
						partial.prependTo wrapper
					else
						partial.appendTo wrapper
				else if data.action_name == "update"
					on_page.replaceWith partial
				
				if has_events && typeof Jibe.events[data.collection][after_hook_name] == "function"
					Jibe.events[data.collection][after_hook_name].call null, partial, data.data, scope
				
				if data.action_name == "destroy"
					on_page.remove()

$ ->
	Jibe.init()

document.addEventListener "page:fetch", Jibe.tearDown
document.addEventListener "page:change", Jibe.init