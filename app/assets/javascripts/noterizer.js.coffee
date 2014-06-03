@Noterizer =
	messages: []
	parsing: false
		
	parseEvents: ->
		if !Noterizer.parsing && Noterizer.messages.length
			Noterizer.parsing = true
			event = Noterizer.messages.shift()
			Noterizer.show event
	
			setTimeout ->
				Noterizer.close ->
					Noterizer.parsing = false
					Noterizer.parseEvents()
			, 1500
	
	open: (content, mode = "success") ->
		Noterizer.messages.push
			content: content
			mode: mode
	
	show: (event) ->
		$("#noterizer").removeClass("failed").removeClass("successed").addClass "#{event.mode}ed"
		$("#noterizer p").text event.content
		$("#noterizer").fadeIn()
	
	close: (callback = false) ->
		$("#noterizer").fadeOut 250, ->
			callback() if typeof callback == "function"

Noterizer.messages.push = (args) ->
	a = Array.prototype.push.call this, args
	setTimeout Noterizer.parseEvents, 20
	a