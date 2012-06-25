app = require '../../app'
url = require 'url'
path = require 'path'
request = require 'request'
gm = require 'gm'
rest = require '../rest'
fs = require 'fs'

Config = require '../../config'

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')
fileId = null

module.exports =
  testImageUpload: (test)->
    filename = './test/data/han.jpg'
    start = new Date().getTime()
    rest.upload serverUrl,
      [filename, filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        file = files[0]
        fileId = file.id
        test.ok file.width, 'No width'
        rest.get serverUrl + file.id,
          success: (data, response)->
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()

  testImageDownload: (test)->
    json =
      url: serverUrl + fileId
      filename: "file.jpg"

    # Send the json to download the file
    rest.postJson serverUrl, json,
      success: (file, response)=>
        # Get the file
        rest.get serverUrl + fileId,
          success: (data, response)=>
            test.equal response.statusCode, 200
            test.done()

  testCustomCrop: (test)->
    filePath = path.join Config.tmpDir, 'customCropTest.png'
    request(serverUrl + "thumb/#{fileId}/w:300,h:300,x:5,y:30", (err, response)=>
      test.ifError err
      gm(filePath).size (err, value)=>
        test.ifError err
        test.equal 300, value.width
        test.equal 300, value.height
        test.done()
    ).pipe(fs.createWriteStream(filePath))

