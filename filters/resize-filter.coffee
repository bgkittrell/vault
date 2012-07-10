gm = require 'gm'

class ResizeFilter
  constructor: (@format, @settings)->
  filter: ([file, options]..., cb)->
    n = file.filename(@format)
    if n not in file.contents
      path = if @settings.file then file.join(@settings.file) else file.path()
      gm(path).resize(@settings.w, @settings.h).write file.path(@format), (error)=>
        file.refresh()
        cb(file.path(@format))
    else
      cb(file.path(@format))

module.exports = ResizeFilter

