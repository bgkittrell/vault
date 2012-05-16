uuid = require 'node-uuid'
rest = require 'restler'
fs = require 'fs-extra'
path = require 'path'
gm = require 'gm'
mkdirp = require 'mkdirp'

Config = require '../config'

class File
  constructor: (@id, @originalName, @contents) ->
  directory: () ->
    return @dir ||= File.directory(@id)
  filename: (type = 'original')->
    return @originalName if type == 'original' && @originalName
    throw new Error("Invalid type: #{type}") unless type.match /^\w+$/

    name = (file for file in @contents when file.match ///\.#{type}\.\w+$///).toString()
    unless name || type == 'original'
      name = @fixType type

    return name
  fixType: (type)->
    @originalName.replace(/(.*\.)original\.(\w+)$/, "$1#{type}.$2")
  path: (type) ->
    if @filename() && @directory()
      return path.join @directory(), @filename(type)
    else
      throw new Error("#{@id} Not Found")
  join: (paths)->
    path.join @directory(), paths
  get: (name)->
    value = (file for file in @contents when file.match ///#{name}///)
    value.toString() if value
  value: (name)->
    value = @get(name)
    value.toString().split('.')[0] if value
  values: (name, delim = 'x')->
    value = @value(name)
    value.split(delim) if value
  json: ->
    id: @id
    finished: true
  fetch: (type, callback)->
    callback.call(@)
  create: (callback)->
    callback.call(@)
  @directory: (id)->
    throw new Error("Invalid id: #{id}") unless id.match /^[\w-]+$/

    first = id.substring(0,2)
    second = id.substring(2,4)

    path.join(Config.mediaDir, first, second, id)
  @extension: (name)->
    parts = name.split('.')
    return parts[parts.length-1]
  @create: (name, callback) ->
    id = uuid.v4()
    originalName =  name.replace(/\ /, '-').replace(/[^A-Za-z0-9\.\-_]/, '').replace(/(.*\.)(\w+)$/, '$1original.$2').toLowerCase()

    clazz = File.clazz(originalName)
    file = new clazz(id, originalName, [originalName])

    mkdirp.sync(file.directory())

    file.create ()->
      callback(file)
  @fetch: (id, type, callback) ->
    dirContents = fs.readdirSync(File.directory(id))
    name = (file for file in dirContents when file.match ///\.original\.\w+$///).toString()

    clazz = File.clazz(name)
    file = new clazz(id, name, dirContents)
    file.fetch type, ()->
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
