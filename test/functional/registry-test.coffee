url = require 'url'
app = require '../../app'
request = require 'request'

Config = require '../../config'
Secure = require '../../secure'

module.exports =
  testGetUnauth: (test)->
    request.get Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 401
      test.done()
  testPostUnauth: (test)->
    request.post Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 401
      test.done()
  testPutUnauth: (test)->
    request.put Config.serverUrl() + 'registry', (err, response, body)=>
      test.equal response.statusCode, 401
      test.done()

  testGet: (test)->
    request.get Secure.systemUrl() + 'registry', (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.ok registry.writeable, "Registry isn't Writeable"
      test.equal Config.serverUrl(), registry.master
      test.deepEqual [], registry.slaves
      test.done()

  testAdd: (test)->
    request.post Secure.systemUrl() + 'registry', json: { slaveUrl: 'http://slave:7000' }, (err, response, registry)=>
      test.ifError err
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()

  testGetAgain: (test)->
    request.get Secure.systemUrl() + 'registry',  (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.deepEqual ['http://slave:7000'], registry.slaves
      test.done()
  testReset: (test)->
    request.put Secure.systemUrl() + 'registry',
      json: { master: Config.serverUrl() },  (err, response, registry)=>
        test.ifError err
        test.equal response.headers['content-type'], 'application/json'
        test.equal Config.serverUrl(), registry.master
        test.equal 0, registry.slaves.length
        test.done()
