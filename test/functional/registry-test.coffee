url = require 'url'
app = require '../../app'
request = require 'request'

Config = require '../../config'

module.exports =
  testGetUnauth: (test)->
    request.get Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 403
      test.done()
  testPostUnauth: (test)->
    request.post Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 403
      test.done()
  testPutUnauth: (test)->
    request.put Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 403
      test.done()

  testGet: (test)->
    request.get Config.serverUrl() + 'registry', headers: {'X-Vault-Key': Config.systemKey }, (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.ok registry.writeable, "Registry isn't Writeable"
      test.equal Config.serverUrl(), registry.master
      test.deepEqual [], registry.slaves
      test.done()

  testAdd: (test)->
    request.post Config.serverUrl() + 'registry', json: { slaveUrl: 'http://slave:7000' }, headers: {'X-Vault-Key': Config.systemKey }, (err, response, registry)=>
      test.ifError err
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()

  testGetAgain: (test)->
    request.get Config.serverUrl() + 'registry',  headers: {'X-Vault-Key': Config.systemKey }, (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()
  testReset: (test)->
    request.put Config.serverUrl() + 'registry',
      json: { master: Config.serverUrl() },  headers: {'X-Vault-Key': Config.systemKey }, (err, response, registry)=>
        test.ifError err
        test.equal response.headers['content-type'], 'application/json'
        test.equal Config.serverUrl(), registry.master
        test.equal 0, registry.slaves.length
        test.done()
