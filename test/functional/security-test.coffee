app = require '../../app'
rest = require '../rest'
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
    rest.upload Secure.systemUrl(),
      [filename],
      failure: (response)=>
        test.ok false, "Request was denied"
        test.done()
      success: (files)=>
        testFile = files[0]
        test.done()
  postUnauthenticated: (test)->
    filename = './test/data/han.jpg'
    rest.upload Config.serverUrl(),
      [filename],
      success: ()=>
        test.ok false, "Should get a 403"
      failure: (response)=>
        test.equals response.statusCode, 404
        test.done()
  getUnauthenticated: (test)->
    rest.get Config.serverUrl() + testFile.id,
      success: ()=>
        test.ok false, "Should get a 404"
      failure: (response)=>
        test.equals response.statusCode, 403
        test.done()
  deleteUnauthenticated: (test)->
    rest.delete Config.serverUrl() + testFile.id,
      success: ()=>
        test.ok false, "Should get a 404"
        test.done()
      failure: (response)=>
        test.equals response.statusCode, 404
        test.done()
  systemSuite:
    getUnauthenticated: (test)->
      rest.get Secure.secureUrl(testFile.id, 'system', 'asdfasdfsd'),
        success: ()=>
          test.ok false, "Should get a 403"
          test.done()
        failure: (response)=>
          test.equals response.statusCode, 403
          test.done()
    getUnauthorized: (test)->
      rest.get Secure.apiUrl(Config.serverUrl() + 'registry'),
        success: ()=>
          test.ok false, "Should get a 403"
          test.done()
        failure: (response)=>
          test.equals response.statusCode, 403
          test.done()
    getAuthenticated: (test)->
      rest.get Secure.systemUrl(testFile.id),
        success: (files, response)=>
          test.equals response.statusCode, 200
          test.done()
  apiSuite:
    getAuthenticated: (test)->
      rest.get Secure.apiUrl(testFile.id),
        success: (files, response)=>
          test.equals response.statusCode, 200
          test.done()
  userSuite:
    getUnuthenticated: (test)->
      username = 'sam'
      password = 'benspw'

      rest.get Secure.secureUrl(testFile.id, username, password),
        success: ()=>
          test.ok false, "Should get a 403"
          test.done()
        failure: (response)=>
          test.equals response.statusCode, 403
          test.done()
    getUnauthorized: (test)->
      username = 'sam'
      password = 'samspw'

      rest.get Secure.secureUrl(testFile.id, username, password),
        success: ()=>
          test.ok false, "Should get a 403"
          test.done()
        failure: (response)=>
          test.equals response.statusCode, 403
          test.done()
    getAuthenticated: (test)->
      username = 'ben'
      password = 'benspw'

      rest.get Secure.secureUrl(testFile.id, username, password),
        failure: (response)=>
          test.ok false, "Request was denied"
          test.done()
        success: (files, response)=>
          test.equals response.statusCode, 200
          test.done()
    shutdownServer: (test)->
      server.close()
      test.done()
