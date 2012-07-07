app = require('../../app')
url = require 'url'
sys = require 'util'
rest = require '../rest'
fs = require 'fs'
hash = require '../../util/hash'

Config = require '../../config'
Secure = require '../../secure'
Profile = require '../../models/profile'
VideoTranscoder = require '../../models/video-transcoder'

VideoTranscoder.prototype.start = (file)->
  console.log "Bypassing Zencoder"

zencoderResponse =  (thumbUrl, audioUrl)->
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

    rest.upload Secure.systemUrl(),
      [filename,image],
      { profile: 'audio' },
      success: (files)=>
        end = new Date().getTime()
        audio = files[0]
        image = files[1]
        post = zencoderResponse(Secure.apiUrl() + image.id, Secure.apiUrl() + audio.id)
        count = 0
        profile = new Profile('video', Config.profiles.audio)
        formats = hash(profile.formats).filter((k,v)-> v.transcoder)
        for name, format of formats
          rest.postJson Secure.systemUrl(name + '/' + audio.id), post,
            success: (data, response)=>
              test.equal response.statusCode, 200
              count++
              if count == hash(formats).keys().length
                rest.get Secure.systemUrl(audio.id + '.status'),
                  success: (data)=>
                    status = data
                    test.equal status.status, 'finished'
                    test.done()

