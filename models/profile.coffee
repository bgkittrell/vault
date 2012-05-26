hash = require '../util/hash'

class Profile
  constructor: (@name, profile = {})->
    @extensions = profile.extensions || []
    @metaFilter = profile.metaFilter
    @formats = hash(profile).clone()
    delete @formats['extensions']
    delete @formats['metaFilter']
  filter: (format)->
    if f = @formats[format]
      return f.filter
  transcoder: (format)->
    if f = @formats[format]
      return f.transcoder

module.exports = Profile
