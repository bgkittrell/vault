request = require 'request'
async = require 'async'
fs = require 'fs'
{Zencoder} = require 'zencoder'
hash = require '../util/hash'
Config = require '../config'

class VideoTranscoder
  start: (file)=>
    outputs = []
    for name, format of file.profile().formats
      continue unless format.transcoder
      options = hash(format.transcoder).first()
      hash(options).merge
        public: no
        notifications: [
          Config.apiUrl() + name + '/' + file.id
        ]
      outputs.push options

    Zencoder::api_key = Config.zencoderKey
    Zencoder::Job.create
      input: Config.apiUrl() + file.id
      outputs: outputs

    console.log "Sending job request #{Config.serverUrl() + file.id}"
    console.log outputs

  finish: (file, notification, formatName,  callback)=>
    request(notification.output.url, (err)=>
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
        request(thumbImage.url, (err)->
          async.forEach props, setProp, ()->
            callback.call(file)
        ).pipe(fs.createWriteStream(file.join("#{label}.png")))
      else
        async.forEach props, setProp, ()->
          callback.call(file)

    ).pipe(fs.createWriteStream(file.path(formatName)))


module.exports = VideoTranscoder

