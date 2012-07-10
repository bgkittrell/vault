client = require '../util/http-client'

Secure = require '../secure'
Config = require '../config'

module.exports = (app)->
  if Config.masterUrl
    console.log "Initializing slave %s with master: %s", Config.serverUrl(), Config.masterUrl
    data = slaveUrl: Config.serverUrl()
    client.postJson Secure.systemUrl(Config.masterUrl + 'registry'), data, (err,body,response)=>
      if err
        throw new Error(err)
      if response.statusCode == 200
        app.registry = new Registry(body.master, body.slaves, body.writeable)
        console.log "Successfully registered with master: URL %s", Config.masterUrl
      else
        console.error "Couldn't register with master: URL %s", Config.masterUrl
  else
    console.log "Initializing registry as master: URL %s", Config.serverUrl()
    app.registry = new Registry(Config.serverUrl())

  app.get '/secure/:auth/registry', Secure.app, (req, res, next)=>
      res.contentType 'json'
      res.end(JSON.stringify(app.registry.json()))
  app.post '/secure/:auth/registry', Secure.system, (req, res, next)=>
    res.contentType 'json'
    slaves = app.registry.slaves.slice(0)
    app.registry.register req.param('slaveUrl')
    for slave in slaves
      console.log "Sending sync request to %s", slave
      client.putJson Secure.systemUrl(slave) + 'registry', app.registry.json(), (err,body,res)=>
        if err
          console.error "Couldn't sync registry with slave: %s errror: %s", slave, err
    res.end(JSON.stringify(app.registry.json()))
  app.put '/secure/:auth/registry', Secure.system, (req, res, next)=>
    res.contentType 'json'
    app.registry = new Registry(req.body.master, req.body.slaves, req.body.writeable)
    console.log "Received sync request from master %s", app.registry.master
    res.end(JSON.stringify(app.registry.json()))


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
