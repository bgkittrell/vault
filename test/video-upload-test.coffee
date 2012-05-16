app = require('../app')

sys = require 'util'
rest = require './rest'
fs = require 'fs'
Config = require '../config'
Video = require '../models/video'

Video.prototype.transcode = ()->
  console.log "Don't actually send to zencoder"

url = "http://localhost:7000/"

zencoderResponse =  (thumbUrl, videoUrl)->
  console.log thumbUrl
  console.log videoUrl
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

    rest.upload url,
      [filename, filename],
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        video = files[0]
        image = files[1]
        post = zencoderResponse(url + image.id, url + video.id)
        count = 0
        for name, profile of Config.videoProfiles

          rest.postJson url + profile.format + '/' + video.id, post,
            success: (data, response)=>
              test.equal response.statusCode, 200
              count++
              if count == Object.keys(Config.videoProfiles).length

                rest.get url + video.id + '.status',
                  success: (data)=>
                    status = data
                    console.log status
                    test.equal status.status, 'finished'
                    test.done()

