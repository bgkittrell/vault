mime = require 'mime'
fs = require 'fs'
util = require 'util'
path = require 'path'
download = require '../util/download'
json = require '../util/json'

File = require '../models/file'
Config = require '../config'
Synchronizer = require '../models/synchronizer'

class FileController
  constructor: (@app)->
  serve: (req, res, next) =>
    id = req.params.fileId
    format = req.params.format
    options = json.parse(req.params.options) if req.params.options

    File.fetch id, format, options, (file, filePath)=>
      filePath ||= file.path(format)
      if file
        fs.stat filePath, (err, stat)=>
          if err
            console.error err
            res.send(404)
          else
            res.writeHead 200,
              'Content-Type': mime.lookup(filePath),
              'Content-Length': stat.size
            
            read = fs.createReadStream filePath
            util.pump read, res
      else
        res.status = 404
        res.end()
  upload: (req, res, next) =>
    created = []

    for key, upload of req.files
      do (key, upload) =>
        if upload.name
          File.create upload.path, upload.name, req.param('profile'), (file)=>
            created.push file.json()

            if created.length == Object.keys(req.files).length
              res.end JSON.stringify(created)
            file.profile().transcode file
            Synchronizer.sync file, @app.registry.slaves
  download: (req, res, next) =>
    params = req.body

    filePath = path.join(Config.tmpDir, params.filename)
    download params.url, filePath, =>
      File.create filePath, params.filename, params.profile, (file)=>
        res.end JSON.stringify(file.json())
        file.profile().transcode file
        Synchronizer.sync file, @app.registry.slaves
  finish: (req, res, next) =>
    id = req.params.fileId
    format = req.params.format

    notification = req.body

    File.fetch id, format, (file)=>
      if file
        if transcoder = file.profile().transcoder(format)
          transcoder.finish file, notification, format, =>
            res.end JSON.stringify(file.json())
            Synchronizer.sync file, @app.registry.slaves
        else
          res.end new Error("No transcoder")
      else
        res.status = 404
        res.end()
  status: (req, res, next) =>
    id = req.params.fileId
    format = req.params.format

    File.fetch id, format, (file)=>
      if file
        res.send(file.json())
      else
        res.status = 404
        res.end()
  delete: (req, res, next) =>
    id = req.params.fileId

    File.delete id, (file)=>
      res.end("ok")


module.exports = FileController
