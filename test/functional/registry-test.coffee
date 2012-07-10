url = require 'url'
app = require '../../server'
client = require '../../util/http-client'

Config = require '../../config'
Secure = require '../../secure'

module.exports =
  testGetUnauthenticated: (test)->
    client.get Config.serverUrl() + 'registry', (err, body, response)=>
      test.equal response.statusCode, 404
      test.done()
  testPostUnauthenticated: (test)->
    client.post Config.serverUrl() + 'registry', (err, body, response)=>
      test.equal response.statusCode, 404
      test.done()
  testPutUnauthenticated: (test)->
    client.put Config.serverUrl() + 'registry', (err, body, response)=>
      test.equal response.statusCode, 404
      test.done()
  testGetUnauthorized: (test)->
    client.get Secure.apiUrl('registry'), (err, body, response)=>
      test.equal response.statusCode, 403
      test.done()
  testPostUnauthorized: (test)->
    client.post Secure.apiUrl('registry'), (err, body, response)=>
      test.equal response.statusCode, 403
      test.done()
  testPutUnauthorized: (test)->
    client.put Secure.apiUrl('registry'), (err, body, response)=>
      test.equal response.statusCode, 403
      test.done()

  testGet: (test)->
    client.get Secure.systemUrl('registry'), (err, body, response)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.ok registry.writeable, "Registry isn't Writeable"
      test.equal Config.serverUrl(), registry.master
      test.deepEqual [], registry.slaves
      test.done()

  testAdd: (test)->
    client.postJson Secure.systemUrl('registry'), { slaveUrl: 'http://slave:7000' }, (err, registry, response)=>
      test.ifError err
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()

  testGetAgain: (test)->
    client.get Secure.systemUrl('registry'),  (err, body, response)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()
  testReset: (test)->
    client.putJson Secure.systemUrl('registry'), { master: Config.serverUrl() },  (err, registry, response)=>
      test.ifError err
      test.equal response.headers['content-type'], 'application/json'
      test.equal Config.serverUrl(), registry.master
      test.equal 0, registry.slaves.length
      test.done()
