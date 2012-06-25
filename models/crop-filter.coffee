gm = require 'gm'
hash = require '../util/hash'

class CropFilter
  constructor: (@format, @settings)->
  filter: ([file, options]..., cb)->
    n = @format
    n = hash(options).values().join('x') + "." + n if options
    fn = file.filename(n)
    console.log "looking for: %s", fn
    if fn not in file.contents
      console.log "Not found"
      path = if @settings.file then file.join(@settings.file) else file.path()
      if options
        console.log "Writing to: %s", file.path(n)
        gm(path).crop(options.w, options.h, options.x, options.y).write file.path(n), (error)->
          console.log "Written to: %s", file.path(n)
          file.refresh()
          console.log file
          cb(file, file.path(n))
      else
        gm(path).thumb @settings.w, @settings.h, file.path(n), @settings.quality || 100, (error)->
          file.refresh()
          cb(file)
    else
      console.log "Found"
      cb(file, file.path(n))

module.exports = CropFilter

