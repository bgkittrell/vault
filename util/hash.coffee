class Hash
  constructor: (@hash)->
  keys: ()=>
    Object.keys(@hash)
  firstKey: ()->
    @keys()[0]
  first: ()->
    @hash[@firstKey()]
  filter: (callback)=>
    hash = {}
    for key, value of @hash
      if callback(key, value)
        hash[key] = value
    return hash
  merge: (override) ->
    for key, value of override
      @hash[key] = value
  clone: ->
    @_clone(@hash)
  values: () ->
    Object.keys(@hash).map (key)=> @hash[key]
  _clone: (obj)->
    if not obj? or typeof obj isnt 'object'
      return obj

    if obj instanceof Date
      return new Date(obj.getTime())

    if obj instanceof RegExp
      flags = ''
      flags += 'g' if obj.global?
      flags += 'i' if obj.ignoreCase?
      flags += 'm' if obj.multiline?
      flags += 'y' if obj.sticky?
      return new RegExp(obj.source, flags)

    newInstance = new obj.constructor()

    for key of obj
      newInstance[key] = @_clone obj[key]

    return newInstance

module.exports = (hash)->
  new Hash(hash)
