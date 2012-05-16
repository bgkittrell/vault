app = require('../app')
sys = require 'util'
rest = require 'restler'
fs = require 'fs'
gm = require 'gm'
Config = require '../config'

url = "http://localhost:7000/"

uploadFile = (callback)->
  filename = './test/data/han.jpg'
  fs.stat filename, (err, stat)=>
    size = stat.size
    rest.post('http://localhost:7000/', {
      multipart: true,
      data: {
        'upload2': rest.file(filename, null, size, null, 'image/jpeg')
      }
    }).on 'complete', callback

module.exports =
  testProfiles: (test)->
    uploadFile (files)->
      count = 0
      keyCount = Object.keys(Config.imageProfiles).length

      for name, profile of Config.imageProfiles
        do (name, profile)->
          console.log "Testing with profile: %s", name
          file = JSON.parse(files)[0]
          rest.get(url + name + '/' + file.id, { encoding: 'binary' }).on('complete', (data, response)->
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
            test.ok false, error
          ).on('error', (error)->
            test.ok false, error
          )
