jQuery.expr[":"].Contains = jQuery.expr.createPseudo((arg) ->
	(elem) ->
		jQuery(elem).find(".search").text().toUpperCase().indexOf(arg.toUpperCase()) >= 0
)

jQuery.fn.order = (asc, fn, callback = false) ->
  fn = fn or (el) ->
    $(el).toUpperCase().text().replace /^\s+|\s+$/g, ""

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

pasteHtmlAtCaret = (html) ->
  sel = undefined
  range = undefined
  if window.getSelection
    sel = window.getSelection()
    if sel.getRangeAt and sel.rangeCount
      range = sel.getRangeAt(0)
      range.deleteContents()
      el = document.createElement("div")
      el.innerHTML = html
      frag = document.createDocumentFragment()
      node = undefined
      lastNode = undefined
      lastNode = frag.appendChild(node) while (node = el.firstChild)
      range.insertNode frag
      if lastNode
        range = range.cloneRange()
        range.setStartAfter lastNode
        range.collapse true
        sel.removeAllRanges()
        sel.addRange range
  else document.selection.createRange().pasteHTML html if document.selection and document.selection.type isnt "Control"