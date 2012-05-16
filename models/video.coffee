rest = require 'restler'
fs = require 'fs'
gm = require 'gm'
{Zencoder} = require 'zencoder'

Config = require '../config'
File = require '../models/file'

class Video extends File
  @extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
  path: (type) ->
    if type == 'thumb'
      return @join('thumb.png')
    else if type == 'poster'
      return @join('poster.png')
    else
      super(type)
  create: (callback)->
    callback.call(@)
    outputs = []
    for name, profile of Config.videoProfiles
      outputs.push
        format: profile.format
        public: no
        notifications: [
          Config.serverUrl + profile.format + '/' + @id
        ]
        thumbnails:
          label: 'thumb'

    @transcode outputs
  transcode: (outputs)->
    Zencoder::api_key = '1e8ef8591b769f1a4b153c2819b7e6e2'
    Zencoder::Job.create
      input: Config.serverUrl + @id
      outputs: outputs
  complete: (type, notification, callback)->
    rest.get(notification.output.url, { encoding: 'binary' }).on 'complete', (data, response)=>
      fs.writeFile @path(type), response.raw, (err)=>
        console.error err if err
        fs.writeFile @join("#{notification.output.state}.#{type}.status"), null, (err)=>
          console.error err if err
          callback.call(@)

        if notification.output.state == 'finished'
          fs.writeFile @join("#{notification.output.duration_in_ms}.#{type}.duration"), null, (err)=>
            console.log error if err

          fs.writeFile @join("#{notification.output.width}x#{notification.output.height}.#{type}.size"), null, (err)=>
            console.log error if err

    unless @poster() or notification.output.state != 'finished'
      thumbImage = notification.output.thumbnails[0].images[0]
      rest.get(thumbImage.url, { encoding: 'binary' }).on 'complete', (data, response)=>
        thumbPath = @join("poster.png")
        console.log "Writing Thumbnail %s", thumbPath
        fs.writeFile thumbPath, response.raw, (err)=>
          gm(thumbPath).thumb 100,100, @join("thumb.png"), 100, ()->

  poster: ->
    @get("poster.png")
  duration: ->
    @value(".duration$")
  size: ->
    @values(".size$")
  status: ->
    for name, profile of Config.videoProfiles
      return 'failed' if @get("failed.#{profile.format}.status$")
    return @value(".status$")
  fixType: (type)->
    @filename().replace(/(.*\.)original\.\w+$/, "$1#{type}")
  json: ->
    size = @size()
    status = @status()
    {
      id: @id
      duration: @duration()
      width: size[0] if size
      height: size[1] if size
      status: status if status
    }


module.exports = Video
