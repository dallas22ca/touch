@Noterizer =
	open: (content, mode = "success") ->
		$("#noterizer").removeClass("failed").removeClass("successed").addClass "#{mode}ed"
		$("#noterizer p").text content
		$("#noterizer").fadeIn()
		setTimeout Noterizer.close, 2700
	
	close: ->
		$("#noterizer").fadeOut()