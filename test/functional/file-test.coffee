app = require '../../app'
url = require 'url'
sys = require 'util'
path = require 'path'
fs = require 'fs'
gm = require 'gm'
request = require 'request'
rest = require '../rest'
hash = require '../../util/hash'

Config = require '../../config'
Secure = require '../../secure'
Profile = require '../../models/profile'

serverUrl = Secure.systemUrl()

module.exports =
  testProfiles: (test)->
    filename = './test/data/han.jpg'
    rest.upload serverUrl,
      [filename],
      success: (files)=>
        count = 0
        profile = new Profile('image', Config.profiles.image)
        keyCount = hash(profile.formats).keys().length

        for name, format of profile.formats
          do (name, format)->
            file = files[0]

            filePath = "/tmp/#{name}#{file.id}"

            request(serverUrl + name + '/' + file.id, (err, response)=>
              test.equal response.statusCode, 200

              count++
              if format.filter
                gm("/tmp/#{name}#{file.id}").size (err, value)->
                  dims = hash(format.filter).first()
                  if dims.w
                    test.equal dims.w, value.width
                  else if dims.h
                    test.equal dims.h, value.height

                  if count == keyCount
                    test.done()
              else
                if count == keyCount
                  test.done()
            ).pipe(fs.createWriteStream(filePath))
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
  testUpload: (test)->
    filename = './test/data/file.original.txt'
    start = new Date().getTime()

    rest.upload serverUrl,
      [filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"

        rest.get serverUrl + files[0].id,
          success: (data, response)=>
            test.ok data.length > 1, 'Returned file is empty'
            test.equal response.statusCode, 200
            test.done()
