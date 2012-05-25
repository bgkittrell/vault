class Profile
  constructor: (name, exts, formats)->
    @name = name
    if formats
      @extensions = exts
      @loadFormats formats
    else
      @loadFormats exts
  loadFormats: (formatsObject)->
    @formats = []
    for name, options of formatsObject
      @formats.push new Format(name, options)
  match: (filename)->
    return false unless @extensions
    parts = filename.split('.')
    ext =  parts[parts.length-1]
    ext in @extensions

class Format
  constructor: (@name, options)->
    @filter = options.filter

  
module.exports = (name, exts, formats)->
  new Profile(name, exts, formats)
