uuid = require 'node-uuid'
rest = require 'restler'
fs = require 'fs-extra'
path = require 'path'
gm = require 'gm'
mkdirp = require 'mkdirp'
touch = require('../util/touch').touch
require('../util/array')

Config = require '../config'

class File
  constructor: (@id, @originalName, @contents) ->
  directory: () ->
    return @dir ||= File.directory(@id)
  filename: (format = 'original')->
    return @originalName if format == 'original' && @originalName
    throw new Error("Invalid format: #{format}") unless format.match /^[\w\.]+$/

    name = @findFormat format
    unless name || format == 'original'
      name = @changeFormat format

    return name
  findFormat: (format)->
    @contents.match ///\.#{format}\.\w+$///
  changeFormat: (format)->
    @originalName.replace(/(.*\.)original\.(\w+)$/, "$1#{format}.$2")
  path: (format) ->
    if @filename() && @directory()
      return path.join @directory(), @filename(format)
    else
      throw new Error("#{@id} Not Found")
  join: (paths)->
    path.join @directory(), paths
  get: (name)->
    console.log @contents
    value = @contents.match ///#{name}///
    value.toString() if value
  set: (pair, cb)->
    key = Object.keys(pair)[0]
    name = "#{pair[key]}.#{key}"
    @contents.push(name) unless name in @contents
    console.log touch
    console.log name
    console.log cb

    touch @join(name), cb
  value: (name)->
    value = @get(name)
    value.toString().split('.')[0] if value
  values: (name, delim = 'x')->
    value = @value(name)
    value.split(delim) if value
  json: ->
    id: @id
    finished: true
  fetch: (format, callback)->
    callback.call(@)
  create: (profile, callback)->
    callback.call(@)
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

    clazz = File.clazz(originalName)
    file = new clazz(id, originalName, [originalName])

    mkdirp.sync(file.directory())
    fs.rename path, file.path()

    file.create profile, ()->
      callback(file)
  @fetch: (id, format, callback) ->
    dirContents = fs.readdirSync(File.directory(id))
    name = dirContents.match ///\.original\.\w+$///

    clazz = File.clazz(name)
    file = new clazz(id, name, dirContents)
    file.fetch format, ()->
      callback(file)
   @clazz: (name)->
     if File.extension(name) in Image.extensions
       return Image
     else if File.extension(name) in Video.extensions
       return Video
     else
       return File

module.exports = File

Image = require '../models/image'
Video = require '../models/video'
