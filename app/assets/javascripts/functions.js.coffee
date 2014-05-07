jQuery.expr[":"].Contains = jQuery.expr.createPseudo((arg) ->
	(elem) ->
		jQuery(elem).find(".search").text().toUpperCase().indexOf(arg.toUpperCase()) >= 0
)

jQuery.fn.order = (asc, fn, callback = false) ->
  fn = fn or (el) ->
    $(el).text().replace /^\s+|\s+$/g, ""

  T = (if asc isnt false then 1 else -1)
  F = (if asc isnt false then -1 else 1)
  @sort (a, b) ->
    a = fn(a)
    b = fn(b)

    return 0  if a is b
    (if a < b then F else T)

  @each (i) ->
    @parentNode.appendChild this
    return

	callback() if typeof callback == "function"