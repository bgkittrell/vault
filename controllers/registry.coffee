request = require 'request'

Config = require '../config'
Registry = require '../models/registry'

class RegistryController
  constructor: ()->
    if Config.masterUrl
      console.log "Initializing registry as slave: URL %s", Config.serverUrl()
      data = slaveUrl: Config.serverUrl()
      request.post
        url: Config.masterUrl + 'registry', json: data, (err,res,body)=>
          if res.statusCode == 200
            @registry = new Registry(body.master, body.slaves, body.writeable)
            console.log "Successfully registered with master: URL %s", Config.masterUrl
          else
            console.error "Couldn't register with master: URL %s", Config.masterUrl
    else
      console.log "Initializing registry as master: URL %s", Config.serverUrl()
      @registry = new Registry(Config.serverUrl())
      console.log @registry
  get: (req, res, next)=>
    res.contentType 'json'
    res.end(JSON.stringify(@registry.json()))
  add: (req, res, next)=>
    res.contentType 'json'
    slaves = @registry.slaves.slice(0)
    @registry.register req.param('slaveUrl')
    for slave in slaves
      console.log "Sending sync request to %s", slave
      request.put slave + 'registry', json: @registry.json(), (err,res,body)=>
        if err
          console.error "Couldn't sync registry with slave: %s errror: %s", slave, err
    res.end(JSON.stringify(@registry.json()))
  sync: (req, res, next)=>
    res.contentType 'json'
    @registry = new Registry(req.body.master, req.body.slaves, req.body.writeable)
    console.log "Received sync request from master %s", @registry.master
    res.end(JSON.stringify(@registry.json()))

module.exports = RegistryController
