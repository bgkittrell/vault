app = require('../app')

sys = require 'util'
rest = require './rest'
fs = require 'fs'
Config = require '../config'
Video = require '../models/video'

Video.prototype.transcode = ()->
  console.log "Don't actually send to zencoder"

url = "http://localhost:7000/"

zencoderResponse =  (thumbUrl, audioUrl)->
  console.log thumbUrl
  console.log audioUrl
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
      "format": "mp3",
      "url": audioUrl,
      "duration_in_ms": 5000,
      "frame_rate": 25.0


module.exports =

  testAudioProfileUpload: (test)->
    filename = './test/data/audio.flv'
    image = './test/data/han.jpg'
    start = new Date().getTime()

    rest.upload url,
      [filename,image],
      { profile: 'audio' },
      success: (files)=>
        end = new Date().getTime()
        console.log "Finished in #{end - start} millis"
        audio = files[0]
        image = files[1]
        post = zencoderResponse(url + image.id, url + audio.id)
        count = 0
        for name, profile of Config.videoProfiles.audio
          console.log "Posting notification for #{name}"
          rest.postJson url + name + '/' + audio.id, post,
            success: (data, response)=>
              test.equal response.statusCode, 200
              count++
              if count == Object.keys(Config.videoProfiles.audio).length
                console.log "Getting status for #{audio.id}"
                rest.get url + audio.id + '.status',
                  success: (data)=>
                    status = data
                    console.log status
                    test.equal status.status, 'finished'
                    test.done()

