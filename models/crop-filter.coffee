gm = require 'gm'

class CropFilter
  constructor: (@format, @settings)->
  filter: (file, cb)->
    n = file.filename(@format)
    if n not in file.contents
      path = if @settings.file then file.join(@settings.file) else file.path()
      gm(path).thumb @settings.w, @settings.h, file.path(@format), @settings.quality || 100, (error)->
        file.refresh()
        cb(file)
    else
      cb(file)

module.exports = CropFilter

