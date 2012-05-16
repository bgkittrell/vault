app = require('../app')

sys = require 'util'
rest = require './rest'
fs = require 'fs'

url = "http://localhost:7000/"


module.exports =
  testUpload: (test)->
    filename = './test/data/file.txt'
    start = new Date().getTime()

    rest.upload 'http://localhost:7000/',
      [filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"

        rest.get url + files[0].id,
          success: (data, response)=>
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()


  testDownload: (test)->
    filename = './test/data/file.txt'
    # Upload a file so we can use it to test downloading it
    rest.upload 'http://localhost:7000/',
      [filename],
      success: (files)=>
        json =
          url: url + files[0].id
          filename: "file.txt"

        # Send the json to download the file
        rest.postJson url, json,
          success: (file, response)=>
            # Get the file
            rest.get url + file.id,
              success: (data, response)=>
                test.equal response.statusCode, 200
                test.done()
