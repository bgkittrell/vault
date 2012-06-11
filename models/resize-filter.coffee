gm = require 'gm'

class ResizeFilter
  constructor: (@format, @settings)->
  filter: (file, cb)->
    n = file.filename(@format)
    if n not in file.contents
      path = if @settings.file then file.join(@settings.file) else file.path()
      gm(path).resize(@settings.w, @settings.h).write file.path(@format), (error)->
        file.refresh()
        cb(file)
    else
      cb(file)

module.exports = ResizeFilter

