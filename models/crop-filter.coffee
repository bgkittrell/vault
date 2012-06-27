gm = require 'gm'
hash = require '../util/hash'

class CropFilter
  constructor: (@format, @settings)->
  filter: ([file, options]..., cb)->
    n = @format
    n = hash(options).values().join('x') + "." + n if options
    fn = file.filename(n)
    if fn not in file.contents
      path = if @settings.file then file.join(@settings.file) else file.path()
      if options
        gm(path).crop(options.w, options.h, options.x, options.y).write file.path(n), (error)->
          file.refresh()
          cb(file, file.path(n))
      else
        gm(path).thumb @settings.w, @settings.h, file.path(n), @settings.quality || 100, (error)->
          file.refresh()
          cb(file)
    else
      cb(file, file.path(n))

module.exports = CropFilter

