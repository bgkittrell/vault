app = require '../../app'
url = require 'url'
path = require 'path'
request = require 'request'
gm = require 'gm'
rest = require '../rest'
fs = require 'fs'

Config = require '../../config'

fileId = null

module.exports =
  testImageUpload: (test)->
    filename = './test/data/han.jpg'
    start = new Date().getTime()
    rest.upload Config.serverUrl(),
      [filename, filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        file = files[0]
        fileId = file.id
        test.ok file.width, 'No width'
        rest.get Config.serverUrl() + file.id,
          success: (data, response)->
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()

  testImageDownload: (test)->
    json =
      url: Config.serverUrl() + fileId
      filename: "file.jpg"

    # Send the json to download the file
    rest.postJson Config.serverUrl(), json,
      success: (file, response)=>
        # Get the file
        rest.get Config.serverUrl() + fileId,
          success: (data, response)=>
            test.equal response.statusCode, 200
            test.done()

  testCustomCrop: (test)->
    filePath = path.join Config.tmpDir, 'customCropTest.png'
    request(Config.serverUrl() + "thumb/#{fileId}/w:300,h:300,x:5,y:30", (err, response)=>
      test.ifError err
      gm(filePath).size (err, value)=>
        test.ifError err
        test.equal 300, value.width
        test.equal 300, value.height
        test.done()
    ).pipe(fs.createWriteStream(filePath))

