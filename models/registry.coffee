class Registry
  constructor: (@master, @slaves = [], @writeable = true)->
  register: (slave)->
    @slaves.push slave
  json: ->
    master: @master
    slaves: @slaves
    writeable: @writeable
      

module.exports = Registry
