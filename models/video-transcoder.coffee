request = require 'request'
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
          Config.serverUrl() + name + '/' + file.id
        ]
        thumbnails:
          label: 'poster'
      outputs.push options

    Zencoder::api_key = Config.zencoderKey
    Zencoder::Job.create
      input: Config.serverUrl() + file.id
      outputs: outputs

    console.log "Sending job request #{Config.serverUrl() + file.id}"
    console.log outputs

  finish: (file, notification, format,  callback)=>
    request(notification.output.url, (err)=>
      throw new Error(err) if err
      unless file.get('poster') or notification.output.state != 'finished' or !notification.output.thumbnails
        thumbImage = notification.output.thumbnails[0].images[0]
        request(thumbImage.url, (err)->
          callback.call(file)
        ).pipe(fs.createWriteStream(file.join("poster.png")))
      else
        callback.call(file)

      file.set status: "#{notification.output.state}.#{format}", ()=>

      if notification.output.state == 'finished'
        if notification.output.duration_in_ms
          file.set duration: "#{notification.output.duration_in_ms}.#{format}"

        if notification.output.width
          file.set size:  "#{notification.output.width}x#{notification.output.height}.#{format}"
    ).pipe(fs.createWriteStream(file.path(format)))


module.exports = VideoTranscoder

