url = require 'url'
app = require '../../server'
client = require '../../util/http-client'

Config = require '../../config'

serverUrl = Config.serverUrl()
console.log "Testing with URL: %s", serverUrl

module.exports =
  testGetUnauth: (test)->
    client.get serverUrl + 'sync/1234-1234-1234-1234-1234/1234', (err, body, response)=>
      test.equal response.statusCode, 404
      test.done()
  testPostUnauth: (test)->
    client.post serverUrl + 'sync', (err, body, response)=>
      test.equal response.statusCode, 404
      test.done()
