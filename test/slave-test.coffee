url = require 'url'
path = require 'path'
request = require 'request'
Config = require '../config'

# Master
app1 = require '../app'
serverUrl1 = url.format(protocol: 'http', hostname: app1.address().address, port: app1.address().port, pathname: '/')
console.log "Testing with URL1: %s", serverUrl1
masterUrl = Config.serverUrl()

# First Slave
Config.serverPort += 1
Config.masterUrl = serverUrl1
slave1Url = Config.serverUrl()

delete require.cache[path.resolve(__dirname, '..', 'app.coffee')]
app2 = require '../app'

serverUrl2 = url.format(protocol: 'http', hostname: app2.address().address, port: app2.address().port, pathname: '/')
console.log "Testing with URL2: %s", serverUrl2

# Second Slave
Config.serverPort += 1
Config.masterUrl = serverUrl1
slave2Url = Config.serverUrl()

delete require.cache[path.resolve(__dirname, '..', 'app.coffee')]
app3 = require '../app'

serverUrl3 = url.format(protocol: 'http', hostname: app3.address().address, port: app3.address().port, pathname: '/')
console.log "Testing with URL3: %s", serverUrl3

module.exports =
  testAutoRegister: (test)->
    # Wait for auto register
    setTimeout ->
      request.get serverUrl1 + 'registry', (err, response, body)=>
        registry = JSON.parse body
        test.equal response.headers['content-type'], 'application/json'
        test.equal masterUrl, registry.master
        test.equal 2, registry.slaves.length
        test.ok slave1Url in registry.slaves
        test.ok slave2Url in registry.slaves
        test.done()
    , 500

  testRegistrySyncSlave1: (test)->
    request.get serverUrl2 + 'registry', (err, response, body)=>
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.equal masterUrl, registry.master
      test.equal 2, registry.slaves.length
      test.ok slave1Url in registry.slaves
      test.ok slave2Url in registry.slaves
      test.done()

  testRegistrySyncSlave2: (test)->
    request.get serverUrl3 + 'registry', (err, response, body)=>
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.equal masterUrl, registry.master
      test.equal 2, registry.slaves.length
      test.ok slave1Url in registry.slaves
      test.ok slave2Url in registry.slaves
      test.done()
  testReset: (test)->
    request.put serverUrl1 + 'registry',
      json: { master: masterUrl }, (err, response, registry)=>
        test.equal response.headers['content-type'], 'application/json'
        test.equal masterUrl, registry.master
        test.equal 0, registry.slaves.length
        app2.close()
        app3.close()
        test.done()
