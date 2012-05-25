unless Array::filter
  Array::find = (callback) ->
    for element in this
      if callback(element)
        return element
    return null
unless Array::match
  Array::match = (re) ->
    for element in this
      if element.match re
        return element
    return null
unless Array::first
  Array::first = () ->
    this[0]
unless Array::last
  Array::last = () ->
    this[this.length-1]
