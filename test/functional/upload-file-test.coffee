app = require '../../app'
url = require 'url'
sys = require 'util'
rest = require '../rest'
fs = require 'fs'

Config = require '../../config'

module.exports =
  testUpload: (test)->
    filename = './test/data/file.original.txt'
    start = new Date().getTime()

    rest.upload Config.serverUrl(),
      [filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"

        rest.get Config.serverUrl() + files[0].id,
          success: (data, response)=>
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()


  testDownload: (test)->
    filename = './test/data/file.txt'
    # Upload a file so we can use it to test downloading it
    rest.upload Config.serverUrl(),
      [filename],
      success: (files)=>
        json =
          url: Config.serverUrl() + files[0].id
          filename: "file.txt"

        # Send the json to download the file
        rest.postJson Config.serverUrl(), json,
          success: (file, response)=>
            # Get the file
            rest.get Config.serverUrl() + file.id,
              success: (data, response)=>
                test.equal response.statusCode, 200
                test.done()
