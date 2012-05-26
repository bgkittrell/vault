request = require 'request'
fs = require 'fs'
{zc} = require 'zencoder'

class Zencoder
  constructor: (@format, @settings)->
  start: (file)->
    outputs = []
    options = @settings
    options = helper.merge options,
      public: no
      notifications: [
        Config.serverUrl() + name + '/' + @id
      ]
      thumbnails:
        label: 'poster'
    outputs.push options

    zc::api_key = Config.zencoderKey
    zc::Job.create
      input: Config.serverUrl() + @id
      outputs: outputs

  finish: (file, notification, callback)->
    request(notification.output.url, (err)->
      throw new Error(err) if err
      unless file.get('poster') or notification.output.state != 'finished' or !notification.output.thumbnails
        thumbImage = notification.output.thumbnails[0].images[0]
        request(thumbImage.url, (err)->
          callback.call(file)
        ).pipe(fs.createWriteStream(file.join("poster.png")))
      else
        callback.call(file)

      file.set status: "#{notification.output.state}.#{@format}", ()=>

      if notification.output.state == 'finished'
        if notification.output.duration_in_ms
          file.set duration: "#{notification.output.duration_in_ms}.#{@format}"

        if notification.output.width
          file.set size:  "#{notification.output.width}x#{notification.output.height}.#{@format}"
    ).pipe(fs.createWriteStream(file.path(@format)))


module.exports = Zencoder

Config = require '../config'
