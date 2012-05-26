class Array
  constructor: (@array)->
  filter: (callback)=>
    arr = []
    for element in @array
      if callback(element)
        arr.push element
    return arr
  find: (callback)=>
    for element in @array
      if callback(element)
        return element
    return null
  match: (re)=>
    for element in @array
      if element.match re
        return element
    return null
  first: ()=>
    @array[0]
  last: ()=>
    @array[@array.length-1]

module.exports = (array)->
  new Array(array)
