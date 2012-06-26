app = require '../../app'
url = require 'url'
sys = require 'util'
rest = require 'restler'
fs = require 'fs'
gm = require 'gm'
hash = require '../../util/hash'

Config = require '../../config'
Profile = require '../../models/profile'

serverUrl = Config.serverUrl()

uploadFile = (callback)->
  filename = './test/data/han.jpg'
  fs.stat filename, (err, stat)=>
    size = stat.size
    rest.post(serverUrl, {
      multipart: true,
      data: {
        'upload2': rest.file(filename, null, size, null, 'image/jpeg')
      }
    }).on 'success', callback

module.exports =
  testProfiles: (test)->
    console.log "Starting test"
    uploadFile (files)->
      count = 0
      profile = new Profile('image', Config.profiles.image)
      keyCount = hash(profile.formats).keys().length

      for name, format of profile.formats
        do (name, format)->
          file = JSON.parse(files)[0]
          rest.get(serverUrl + name + '/' + file.id, { encoding: 'binary' }).on('complete', (data, response)->
            fs.writeFile "/tmp/#{name}#{file.id}", response.raw, (err)->
              test.ok data.length > 1, 'Returned file is empty'
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
          ).on('fail', (error)->
            console.log "FAILURE"
            console.error error
            test.ok false, error
          ).on('error', (error)->
            console.log "ERROR"
            console.error error
            test.ok false, error
          )
