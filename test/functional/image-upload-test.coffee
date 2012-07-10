app = require '../../server'
url = require 'url'
path = require 'path'
gm = require 'gm'
client = require '../../util/http-client'
fs = require 'fs'

Config = require '../../config'
Secure = require '../../secure'

fileId = null

module.exports =
  testImageUpload: (test)->
    filename = './test/data/han.jpg'
    start = new Date().getTime()
    client.upload Secure.systemUrl(), filename, (err, files)=>
      end = new Date().getTime()
      console.log "Finished in #{end - start} millis"
      file = files[0]
      fileId = file.id
      test.ok file.width, 'No width'
      client.get Secure.systemUrl(file.id), (err, data, response)->
        test.ok data.length > 1, 'Returned file is empty'
        test.equal response.statusCode, 200
        test.done()

  testImageDownload: (test)->
    json =
      url: Secure.systemUrl(fileId)
      filename: "file.jpg"

    # Send the json to download the file
    client.postJson Secure.systemUrl(), json, (file, response)=>
      # Get the file
      client.get Secure.systemUrl(fileId), (err, data, response)=>
        test.equal response.statusCode, 200
        test.done()

  testCustomCrop: (test)->
    filePath = path.join Config.tmpDir, 'customCropTest.png'
    client.download Secure.systemUrl("thumb/#{fileId}/w:300,h:300,x:5,y:30"), filePath, (err, response)=>
      test.ifError err
      gm(filePath).size (err, value)=>
        test.ifError err
        test.equal 300, value.width
        test.equal 300, value.height
        test.done()

