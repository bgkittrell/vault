url = require 'url'
app = require '../app'
request = require 'request'

Config = require '../../config'

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')
console.log "Testing with URL: %s", serverUrl

module.exports =
  testGet: (test)->
    request.get serverUrl + 'registry', (err, response, body)=>
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.ok registry.writeable, "Registry isn't Writeable"
      test.equal Config.serverUrl(), registry.master
      test.deepEqual [], registry.slaves
      test.done()

  testAdd: (test)->
    request.post serverUrl + 'registry', json: {slaveUrl: 'http://slave:7000' }, (err, response, registry)=>
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()

  testGetAgain: (test)->
    request.get serverUrl + 'registry', (err, response, body)=>
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()
  testReset: (test)->
    request.put serverUrl + 'registry',
      json: { master: Config.serverUrl() }, (err, response, registry)=>
        test.equal response.headers['content-type'], 'application/json'
        test.equal Config.serverUrl(), registry.master
        test.equal 0, registry.slaves.length
        test.done()
