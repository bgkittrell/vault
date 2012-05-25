app = require '../../app'
url = require 'url'
sys = require 'util'
rest = require 'restler'
fs = require 'fs'
gm = require 'gm'

Config = require '../../config'

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')

uploadFile = (callback)->
  filename = './test/data/han.jpg'
  fs.stat filename, (err, stat)=>
    size = stat.size
    rest.post(serverUrl, {
      multipart: true,
      data: {
        'upload2': rest.file(filename, null, size, null, 'image/jpeg')
      }
    }).on 'complete', callback

module.exports =
  testProfiles: (test)->
    uploadFile (files)->
      count = 0
      keyCount = Object.keys(Config.profiles.image).length

      for name, profile of Config.profiles.image
        do (name, profile)->
          file = JSON.parse(files)[0]
          rest.get(serverUrl + name + '/' + file.id, { encoding: 'binary' }).on('complete', (data, response)->
            fs.writeFile "/tmp/#{name}#{file.id}", response.raw, (err)->
              test.ok data.length > 1, 'Returned file is empty'
              test.equal response.statusCode, 200

              gm("/tmp/#{name}#{file.id}").size (err, value)->
                dims = profile.crop || profile.resize
                if dims.w
                  test.equal dims.w, value.width
                else if dims.h
                  test.equal dims.h, value.height

                count++
                if count == keyCount
                  test.done()
          ).on('fail', (error)->
            console.error error
            test.ok false, error
          ).on('error', (error)->
            console.error error
            test.ok false, error
          )
