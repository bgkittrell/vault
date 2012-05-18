app = require('../app')
sys = require 'util'
rest = require './rest'
fs = require 'fs'

url = "http://localhost:7000/"

module.exports =
  testImageUpload: (test)->
    filename = './test/data/han.jpg'
    start = new Date().getTime()
    console.log "uploading"
    rest.upload url,
      [filename, filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        file = files[0]
        test.ok file.width, 'No width'
        rest.get url + file.id,
          success: (data, response)->
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()

  testImageDownload: (test)->
    filename = './test/data/han.jpg'
    # Upload a file so we can use it to test downloading it
    rest.upload url,
      [filename],
      success: (files)=>
        json =
          url: url + files[0].id
          filename: "file.jpg"

        # Send the json to download the file
        rest.postJson url, json,
          success: (file, response)=>
            # Get the file
            rest.get url + file.id,
              success: (data, response)=>
                test.equal response.statusCode, 200
                test.done()

