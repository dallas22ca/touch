@Event =
	init: ->
		Event.domain = $("body").data("acct")

	track: (data = {}) ->
		img = document.createElement("img")
		img.style.display = "none"
		base64 = encodeURIComponent btoa(JSON.stringify(data))
		img.src = "#{Event.domain}/track/#{base64}"
		document.body.appendChild img