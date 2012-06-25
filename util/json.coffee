module.exports =
  parse: (str)->
    JSON.parse("{" + str.replace(/(\w+):/g, '"$1":') + "}")
