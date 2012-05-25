uuid = require 'node-uuid'
fs = require 'fs-extra'
path = require 'path'
mkdirp = require 'mkdirp'
touch = require('../util/touch').touch
require('../util/array')
require('../util/hash')

Config = require '../config'

class File
  constructor: (@id, @originalName) ->
    console.log @originalName
    if @originalName
      console.log 1
      @contents = []
    else
      console.log 2
      @originalName = @refresh().match ///\.original\.\w+$///

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
    @contents.match ///#{@prefix()}\.#{format}///
  rename: (format)->
    return "#{@prefix()}.#{format}.#{@extension(format)}"
  prefix: ()->
    return @originalName.split('.')[0]
  extension: (format)->
    if profile = Config.profiles[@profile()]
      if format = profile[format]
        if transcode = format.transcode
          return transcode.encoding.format
    return File.extension(@originalName)
  join: (paths)->
    path.join @directory(), paths
  
  # Metadata
  get: (name)->
    value = @contents.match ///#{name}///
    value.toString().split('.')[0] if value
  set: (pair, cb)->
    key = Object.keys(pair)[0]
    name = "#{pair[key]}.#{key}"
    @contents.push(name) unless name in @contents

    touch @join(name), cb
  refresh: ()->
    @contents = fs.readdirSync(@directory())
  values: (name, delim = 'x')->
    value = @get(name)
    value.split(delim) if value
  profile: ->
    @get ".profile$"
  status: ->
    if p = @profile()
      for name, format of Config.profiles[p]
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
  filter: (format)->
    if profile = Config.profiles[@profile()]
      if format = profile[format]
        return format.filter.keys().first()

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

    console.log name
    file = new File(id, originalName)

    mkdirp.sync(file.directory())
    fs.rename path, file.path(), ()->
      file.set profile: profile || File.defaultProfile(name), ->
        callback(file)
  @fetch: (id, format, callback) ->
    file = new File(id)

    if filter = Config.filters[file.filter(format)]
      filter file, format, ->
        callback(file)
    else
      callback(file)
   @delete: (id, callback)->
     File.fetch id, 'original', (file)->
       fs.rename file.path(), path.join(Config.deleteDir, id), callback
   @defaultProfile: (filename)->
     for name, profile of Config.profiles
       if profile.extensions and File.extension(filename) in profile.extensions
         return name
     'default'


module.exports = File
