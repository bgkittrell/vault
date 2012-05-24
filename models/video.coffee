fs = require 'fs'
gm = require 'gm'
{Zencoder} = require 'zencoder'
helper = require('coffee-script').helpers
download = require '../util/download'

Config = require '../config'
File = require '../models/file'

class Video extends File
  @extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
  filename: (format) ->
    if format == 'thumb'
      return 'thumb.png'
    else if format == 'poster'
      return 'poster.png'
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
          Config.serverUrl() + name + '/' + @id
        ]
        thumbnails:
          label: 'thumb'
      outputs.push options

    @transcode outputs
    @set profile: profile || 'default'
  transcode: (outputs)->
    Zencoder::api_key = '1e8ef8591b769f1a4b153c2819b7e6e2'
    Zencoder::Job.create
      input: Config.serverUrl() + @id
      outputs: outputs
  complete: (format, notification, callback)->
    throw new Error('Invalid profile') unless Config.videoProfiles[@profile()][format]
    download notification.output.url, @path(format), =>
      @set status: "#{notification.output.state}.#{format}", ()=>
        callback.call(@)

      if notification.output.state == 'finished'
        if notification.output.duration_in_ms
          @set duration: "#{notification.output.duration_in_ms}.#{format}"

        if notification.output.width
          @set size:  "#{notification.output.width}x#{notification.output.height}.#{format}"

    unless @poster() or notification.output.state != 'finished' or !notification.output.thumbnails
      thumbImage = notification.output.thumbnails[0].images[0]
      thumbPath = @join("poster.png")
      download thumbImage.url, thumbPath, =>
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
    ext = Config.videoProfiles[@profile()][format].encoding.format
    @contents.match ///\.#{ext}$///
  changeFormat: (format)->
    ext = Config.videoProfiles[@profile()][format].encoding.format
    @filename().replace(/(.*\.)original\.\w+$/, "$1#{ext}")
  json: ->
    size = @size()
    status = @status()
    {
      id: @id
      duration: @duration()
      width: size[0] if size
      height: size[1] if size
      status: status if status
      filename: @filename()
    }


module.exports = Video
