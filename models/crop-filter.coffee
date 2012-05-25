gm = require 'gm'
Config = require '../config'

cropFilter = (file, formatName, cb)->
  format = Config.profiles[file.profile()][formatName]
  n = file.filename(formatName)
  if n not in file.contents
    settings = format.filter.crop
    gm(file.path()).thumb settings.w, settings.h, file.path(formatName), settings.quality || 100, ()->
      file.refresh()
      cb(file)
  else
    cb(file)

module.exports = cropFilter

