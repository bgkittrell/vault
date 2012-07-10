gm = require 'gm'

class ImageMeta
  filter: (file, cb)->
    gm(file.path()).size (err, value)=>
      throw new Error(err) if (err)
      file.set size: "#{value.width}x#{value.height}", ->
        cb(file)

module.exports = ImageMeta

