app = require '../../server'
client = require '../../util/http-client'
http = require 'http'
url = require 'url'

Config = require '../../config'
Secure = require '../../secure'

Config.remoteAuthUrl = 'http://localhost:' + (Config.serverPort + 1)

testFile = null

server = http.createServer (req, res)->
  params = url.parse(req.url, true).query
  if params.username is 'ben' and params.password is 'benspw'
    res.writeHead(200, {'Content-Type': 'application/json'})
    res.end "[\"#{testFile.id}\"]"
  if params.username is 'sam' and params.password is 'samspw'
    res.writeHead(200, {'Content-Type': 'application/json'})
    res.end "[\"asdf-asdf-asdf-asdf-asdf\"]"
  else
    res.writeHead(403)
    res.end()

server.listen Config.serverPort + 1

module.exports =
  testSetUp: (test)->
    filename = './test/data/han.jpg'
    client.upload Secure.systemUrl(), filename, (err, files, response)->
      test.ifError err
      test.equal response.statusCode, 200
      testFile = files[0]
      test.done()
  postUnauthenticated: (test)->
    filename = './test/data/han.jpg'
    client.upload Config.serverUrl(), filename, (err, files, response)->
      test.equal response.statusCode, 403
      test.done()
  getUnauthenticated: (test)->
    client.get Config.serverUrl() + testFile.id, (err, files, response)->
      test.equals response.statusCode, 403
      test.done()
  deleteUnauthenticated: (test)->
    client.delete Config.serverUrl() + testFile.id, (err, response)->
      test.equals response.statusCode, 404
      test.done()
  systemSuite:
    getUnauthenticated: (test)->
      client.get Secure.secureUrl(testFile.id, 'system', 'asdfasdfsd'), (err, data, response)->
        test.equals response.statusCode, 403
        test.done()
    getUnauthorized: (test)->
      client.get Secure.apiUrl(Config.serverUrl() + 'registry'), (err, data, response)->
        test.equals response.statusCode, 403
        test.done()
    getAuthenticated: (test)->
      client.get Secure.systemUrl(testFile.id), (err, data, response)->
        test.equals response.statusCode, 200
        test.done()
  apiSuite:
    getAuthenticated: (test)->
      client.get Secure.apiUrl(testFile.id), (err, data, response)->
        test.equals response.statusCode, 200
        test.done()
  userSuite:
    getUnuthenticated: (test)->
      username = 'sam'
      password = 'benspw'

      client.get Secure.secureUrl(testFile.id, username, password), (err, data, response)->
        test.equals response.statusCode, 403
        test.done()
    getUnauthorized: (test)->
      username = 'sam'
      password = 'samspw'

      client.get Secure.secureUrl(testFile.id, username, password), (err, data, response)->
        test.equals response.statusCode, 403
        test.done()
    getAuthenticated: (test)->
      username = 'ben'
      password = 'benspw'

      client.get Secure.secureUrl(testFile.id, username, password), (err, data, response)->
        test.equals response.statusCode, 200
        test.done()
    shutdownServer: (test)->
      server.close()
      test.done()
