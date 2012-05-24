app = require('../app')
url = require 'url'
sys = require 'util'
rest = require './rest'
fs = require 'fs'
Config = require '../config'
Video = require '../models/video'

Video.prototype.transcode = ()->
  console.log "Don't actually send to zencoder"

serverUrl = url.format(protocol: 'http', hostname: app.address().address, port: app.address().port, pathname: '/')

zencoderResponse =  (thumbUrl, videoUrl)->
  "output":
      "thumbnails": [{
          "images": [{
              "format": "PNG",
              "url":thumbUrl,
          }],
          "label": "thumb"
      }],
      "state": "finished",
      "height": 640,
      "width": 480,
      "format": "mpeg4",
      "url": videoUrl,
      "duration_in_ms": 5000,
      "frame_rate": 25.0


module.exports =
  testVideoUpload: (test)->
    filename = './test/data/waves.mov'
    image = './test/data/han.jpg'
    start = new Date().getTime()

    rest.upload serverUrl,
      [filename, filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        video = files[0]
        image = files[1]
        post = zencoderResponse(serverUrl + image.id, serverUrl + video.id)
        count = 0
        for name, profile of Config.videoProfiles.default

          rest.postJson serverUrl + name + '/' + video.id, post,
            success: (data, response)=>
              test.equal response.statusCode, 200
              count++
              if count == Object.keys(Config.videoProfiles.default).length
                rest.get serverUrl + video.id + '.status',
                  success: (data)=>
                    status = data
                    test.equal status.status, 'finished'
                    test.done()

  testVideoProfileUpload: (test)->
    filename = './test/data/waves.mov'
    image = './test/data/han.jpg'
    start = new Date().getTime()

    rest.upload serverUrl,
      [filename, filename],
      { profile: 'stupeflix' },
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        video = files[0]
        image = files[1]
        post = zencoderResponse(serverUrl + image.id, serverUrl + video.id)
        count = 0
        for name, profile of Config.videoProfiles.stupeflix

          rest.postJson serverUrl + name + '/' + video.id, post,
            success: (data, response)=>
              test.equal response.statusCode, 200
              count++
              if count == Object.keys(Config.videoProfiles.stupeflix).length
                rest.get serverUrl + video.id + '.status',
                  success: (data)=>
                    status = data
                    test.equal status.status, 'finished'
                    test.done()

