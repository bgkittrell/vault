gm = require 'gm'
fs = require 'fs'
Config = require '../config'
File = require '../models/file'

class Image extends File
  @extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff']
  create: (callback)->
    callback.call(@)
    gm(@path()).size (err, value)=>
      throw new Error(err) if (err)
      @width = value.width
      @height = value.height
      fs.writeFile @join("#{@width}x#{@height}.size"), "", (err)=>
        throw new Error(err) if (err)
  fetch: (type, callback)->
    if type
      n = @filename(type)
      if n not in @contents and profile = Config.imageProfiles[type]
        if profile.crop
          gm(@path()).thumb(profile.crop.w, profile.crop.h, @path(type), 100, callback)
        else if profile.resize
          gm(@path()).resize(profile.resize.w, profile.resize.h).write @path(type), callback
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
