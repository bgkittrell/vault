gm = require 'gm'
Config = require '../config'
File = require '../models/file'

class Image extends File
  @extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff']
  create: (profile, callback)->
    gm(@path()).size (err, value)=>
      throw new Error(err) if (err)
      @width = value.width
      @height = value.height
      @set size: "#{@width}x#{@height}", ->
        callback.call(@)
  fetch: (format, callback)->
    if format
      n = @filename(format)
      if n not in @contents and profile = Config.imageProfiles[format]
        if profile.crop
          gm(@path()).thumb(profile.crop.w, profile.crop.h, @path(format), 100, callback)
        else if profile.resize
          gm(@path()).resize(profile.resize.w, profile.resize.h).write @path(format), callback
      else
        callback.call(@)
    else
      callback.call(@)
  json: ->
    id: @id
    width: @width
    height: @height
    finished: true

module.exports = Image
