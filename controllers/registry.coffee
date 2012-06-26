request = require 'request'

Registry = require '../models/registry'
Config = require '../config'
Secure = require '../secure'

class RegistryController
  constructor: (@app)->
  get: (req, res, next)=>
    res.contentType 'json'
    res.end(JSON.stringify(@app.registry.json()))
  add: (req, res, next)=>
    res.contentType 'json'
    slaves = @app.registry.slaves.slice(0)
    @app.registry.register req.param('slaveUrl')
    for slave in slaves
      console.log "Sending sync request to %s", slave
      request.put Secure.systemUrl(slave) + 'registry', json: @app.registry.json(), (err,res,body)=>
        if err
          console.error "Couldn't sync registry with slave: %s errror: %s", slave, err
    res.end(JSON.stringify(@app.registry.json()))
  sync: (req, res, next)=>
    res.contentType 'json'
    @app.registry = new Registry(req.body.master, req.body.slaves, req.body.writeable)
    console.log "Received sync request from master %s", @app.registry.master
    res.end(JSON.stringify(@app.registry.json()))

module.exports = RegistryController
