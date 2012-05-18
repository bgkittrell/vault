rest = require 'restler'
fs = require 'fs'
gm = require 'gm'
{Zencoder} = require 'zencoder'
helper = require('coffee-script').helpers

Config = require '../config'
File = require '../models/file'

class Video extends File
  @extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
  path: (format) ->
    if format == 'thumb'
      return @join('thumb.png')
    else if format == 'poster'
      return @join('poster.png')
    else
      super(format)
  create: (profile, callback)->
    callback.call(@)
    outputs = []
    videoProfile = if profile then Config.videoProfiles[profile] else Config.videoProfiles.default
    for name, format of videoProfile
      options = format.encoding
      options = helper.merge options,
        public: no
        notifications: [
          Config.serverUrl + name + '/' + @id
        ]
        thumbnails:
          label: 'thumb'
      outputs.push options

    @transcode outputs
    @set profile: profile || 'default'
  transcode: (outputs)->
    Zencoder::api_key = '1e8ef8591b769f1a4b153c2819b7e6e2'
    Zencoder::Job.create
      input: Config.serverUrl + @id
      outputs: outputs
  complete: (format, notification, callback)->
    throw new Error('Invalid profile') unless Config.videoProfiles[@profile()][format]
    rest.get(notification.output.url, { encoding: 'binary' }).on 'complete', (data, response)=>
      console.log "Sub-profile: " +  format
      console.log "Profile: " +  @profile()
      ext = Config.videoProfiles[@profile()][format].encoding.format
      fs.writeFile @path("#{ext}"), response.raw, (err)=>
        throw new Error(err) if err
        @set status: "#{notification.output.state}.#{format}", ()=>
          callback.call(@)

        if notification.output.state == 'finished'
          if notification.output.duration_in_ms
            @set duration: "#{notification.output.duration_in_ms}.#{format}"

          if notification.output.width
            @set size:  "#{notification.output.width}x#{notification.output.height}.#{format}"

    unless @poster() or notification.output.state != 'finished' or !notification.output.thumbnails
      thumbImage = notification.output.thumbnails[0].images[0]
      rest.get(thumbImage.url, { encoding: 'binary' }).on 'complete', (data, response)=>
        thumbPath = @join("poster.png")
        console.log "Writing Thumbnail %s", thumbPath
        fs.writeFile thumbPath, response.raw, (err)=>
          gm(thumbPath).thumb 100,100, @join("thumb.png"), 100, ()->

  poster: ->
    @get "poster.png"
  duration: ->
    @value ".duration$"
  size: ->
    @values ".size$"
  profile: ->
    @value ".profile$" || 'default'
  status: ->
    for name, format of Config.videoProfiles[@profile]
      return 'failed' if @get("failed.#{format}.status$")
    return @value(".status$")
  findFormat: (format)->
    @contents.match ///\.#{format}$///
  changeFormat: (format)->
    @filename().replace(/(.*\.)original\.\w+$/, "$1#{format}")
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
