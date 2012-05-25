app = require('../../app')
url = require 'url'
sys = require 'util'
rest = require '../rest'
fs = require 'fs'
path = require 'path'
Config = require '../../config'

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')

module.exports =
  testDelete: (test)->
    filename = './test/data/han.jpg'
    rest.upload serverUrl,
      [filename],
      success: (files)=>
        file = files[0]
        rest.delete serverUrl + file.id,
          success: (files, response)=>
            fs.statSync path.join(Config.deleteDir, file.id)
            test.equal response.statusCode, 200
            test.done()
