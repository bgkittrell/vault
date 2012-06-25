url = require 'url'
app = require '../../app'
request = require 'request'

Config = require '../../config'

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')
console.log "Testing with URL: %s", serverUrl

module.exports =
  testGetUnauth: (test)->
    request.get serverUrl + 'sync/1234-1234-1234-1234-1234/1234', (err, response, body)=>
      test.equal response.statusCode, 403
      test.done()
  testPostUnauth: (test)->
    request.post serverUrl + 'sync', (err, response, body)=>
      test.equal response.statusCode, 403
      test.done()
