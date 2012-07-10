app = require '../../server'
url = require 'url'
sys = require 'util'
path = require 'path'
fs = require 'fs'
gm = require 'gm'
client = require '../../util/http-client'
hash = require '../../util/hash'

Config = require '../../config'
Secure = require '../../secure'
Profile = require '../../models/profile'

serverUrl = Secure.systemUrl()

module.exports =
  testProfiles: (test)->
    filename = './test/data/han.jpg'
    client.upload serverUrl, filename, (err, files, response)=>
      count = 0
      profile = new Profile('image', Config.profiles.image)
      keyCount = hash(profile.formats).keys().length

      for name, format of profile.formats
        do (name, format)->
          file = files[0]

          filePath = "/tmp/#{name}#{file.id}"

          client.download Secure.systemUrl(name + '/' + file.id), filePath, (err, response)=>
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
  testDelete: (test)->
    filename = './test/data/han.jpg'
    client.upload serverUrl, filename, (err, files)=>
      file = files[0]
      client.delete Secure.systemUrl(file.id), (err, response)=>
        fs.statSync path.join(Config.deleteDir, file.id)
        test.equal response.statusCode, 200
        test.done()
  testUpload: (test)->
    filename = './test/data/file.original.txt'
    start = new Date().getTime()

    client.upload serverUrl, filename, (err, files)=>
      end = new Date().getTime()
      console.log "Finished in #{end - start} millis"

      client.get Secure.systemUrl(files[0].id), (err, data, response)=>
        test.ok data.length > 1, 'Returned file is empty'
        test.equal response.statusCode, 200
        test.done()
  testMakePublic: (test)->
    console.log "Test Make Public"
    filename = './test/data/file.original.txt'
    start = new Date().getTime()

    client.upload serverUrl, filename, { public: true }, (err, files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"

        client.get Config.serverUrl() + files[0].id, (err, data, response)=>
          test.equal response.statusCode, 200
          test.ok data.length > 1, 'Returned file is empty'
          test.done()
