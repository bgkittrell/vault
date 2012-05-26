uuid = require 'node-uuid'
fs = require 'fs-extra'
path = require 'path'
mkdirp = require 'mkdirp'
touch = require '../util/touch'
array = require '../util/array'
hash = require '../util/hash'

Config = require '../config'
Profile = require './profile'

class File
  constructor: (@id, @originalName) ->
    if @originalName
      @contents = []
    else
      @originalName = array(@refresh()).match ///\.original\.\w+$///

  # Filesystem
  directory: () ->
    return @dir ||= File.directory(@id)
  filename: (format = 'original')->
    return @originalName if format == 'original' && @originalName
    throw new Error("Invalid format: #{format}") unless format.match /^[\w\.]+$/

    name = @findFormat format
    unless name || format == 'original'
      name = @rename format

    return name
  path: (format) ->
    if @filename(format) && @directory()
      return path.join @directory(), @filename(format)
    else
      throw new Error("#{@id} Not Found")
  findFormat: (format)->
    array(@contents).match ///#{@prefix()}\.#{format}///
  rename: (format)->
    return "#{@prefix()}.#{format}.#{@extension(format)}"
  prefix: ()->
    return @originalName.split('.')[0]
  extension: (format)->
    if format = @profile().formats[format]
      if transcoder = format.transcoder
        return transcoder.settings.format
    return File.extension(@originalName)
  join: (paths)->
    path.join @directory(), paths
  
  # Metadata
  get: (name)->
    value = array(@contents).match ///#{name}///
    value.toString().split('.')[0] if value
  set: (pair, cb)->
    key = hash(pair).firstKey()
    console.log key
    name = "#{pair[key]}.#{key}"
    console.log name
    @contents.push(name) unless name in @contents

    touch @join(name), cb
  refresh: ()->
    @contents = fs.readdirSync(@directory())
  values: (name, delim = 'x')->
    value = @get(name)
    value.split(delim) if value
  status: ->
    for name, format of @profile().formats
      return 'failed' if @get("failed.#{format}.status$")
    return @get(".status$")
  json: ->
    size = @values('size')
    duration = @get('duration')
    status = @status()
    {
      id: @id
      duration: duration
      width: size[0] if size
      height: size[1] if size
      status: status
      filename: @filename()
    }
  profile: ->
    p = @get ".profile$"
    new Profile(p, Config.profiles[p])

  # Static
  @directory: (id)->
    throw new Error("Invalid id: #{id}") unless id.match /^[\w-]+$/

    first = id.substring(0,2)
    second = id.substring(2,4)

    path.join(Config.mediaDir, first, second, id)
  @extension: (name)->
    parts = name.split('.')
    return parts[parts.length-1]
  @create: (path, name, profile, callback) ->
    id = uuid.v4()
    originalName =  name.replace(/\ /, '-').replace(/[^A-Za-z0-9\.\-_]/, '').replace(/(.*\.)(\w+)$/, '$1original.$2').toLowerCase()

    file = new File(id, originalName)

    mkdirp.sync(file.directory())
    fs.rename path, file.path(), ()->
      file.set profile: profile || File.defaultProfile(name), ->
        console.log "Profile: " + file.profile().name
        File.meta file, callback

    File.transcoder file
  @fetch: (id, format, callback) ->
    file = new File(id)
    File.filter file, format, callback

  @delete: (id, callback)->
    File.fetch id, 'original', (file)->
      fs.rename file.path(), path.join(Config.deleteDir, id), callback
  @defaultProfile: (filename)->
    for name, profile of Config.profiles
      if profile.extensions and File.extension(filename) in profile.extensions
        return name
    'default'

  @transcoder: (file, callback)->
    for format in file.profile().formats
      if transcoder = format.transcoder
        transcoder.start file
  @meta: (file, callback)->
    if meta = file.profile().metaFilter
      meta.filter file, ->
        callback(file)
    else
      callback(file)
  @filter: (file, format, callback)->
    if format && filter = file.profile().filter(format)
      filter.filter file, ->
        callback(file)
    else
      callback(file)

module.exports = File
