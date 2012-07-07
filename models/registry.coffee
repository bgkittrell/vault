Config = require '../config'

class Registry
  constructor: (@master, @slaves = [], @writeable = true)->
  register: (slave)->
    @slaves.push slave
  json: ->
    master: @master
    slaves: @slaves
    writeable: @writeable
  others: ()->
    unless @siblings
      @siblings = []
      @siblings.push @master unless @master is Config.serverUrl()
      for slave in @slaves
        @siblings.push slave unless slave is Config.serverUrl()

    return @siblings
      

module.exports = Registry
