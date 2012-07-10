async = require 'async'
fs = require 'fs'
{Zencoder} = require 'zencoder'
hash = require '../util/hash'
client = require '../util/http-client'
Config = require '../config'
Secure = require '../secure'

class VideoTranscoder
  start: (file)=>
    outputs = []
    for name, format of file.profile().formats
      continue unless format.transcoder
      options = hash(format.transcoder).first()
      hash(options).merge
        public: no
        notifications: [
          Secure.apiUrl(name + '/' + file.id)
        ]
      outputs.push options

    Zencoder::api_key = Config.zencoderKey
    Zencoder::Job.create
      input: Secure.apiUrl(file.id)
      outputs: outputs

  finish: (file, notification, formatName,  callback)=>
    client.download notification.output.url, file.path(formatName), (err)=>
      setProp = (prop, callback)->
        file.set prop, callback
      props = [ status: "#{notification.output.state}.#{formatName}" ]

      if notification.output.state == 'finished'
        if notification.output.duration_in_ms
          props.push  duration: "#{notification.output.duration_in_ms}.#{formatName}"

        if notification.output.width
          props.push size:  "#{notification.output.width}x#{notification.output.height}.#{formatName}"

      if notification.output.state == 'finished' and notification.output.thumbnails
        thumbImage = notification.output.thumbnails[0].images[0]
        label = notification.output.thumbnails[0].label
        client.download thumbImage.url, file.join("#{label}.png"), (err)->
          async.forEach props, setProp, ()->
            callback.call(file)
      else
        async.forEach props, setProp, ()->
          callback.call(file)

module.exports = VideoTranscoder

