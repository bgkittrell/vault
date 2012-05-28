mime = require 'mime'
fs = require 'fs'
util = require 'util'
path = require 'path'
download = require '../util/download'

File = require '../models/file'
Config = require '../config'

class FileController
  serve: (req, res, next) ->
    id = req.params.fileId
    format = req.params.format

    File.fetch id, format, (file)=>
      stat = fs.statSync(file.path(format))
      res.writeHead 200,
        'Content-Type': mime.lookup(file.filename(format)),
        'Content-Length': stat.size
      
      read = fs.createReadStream file.path(format)
      util.pump read, res
  upload: (req, res, next) ->
    created = []

    for key, upload of req.files
      do (key, upload) =>
        if upload.name
          File.create upload.path, upload.name, req.param('profile'), (file)->
            created.push file.json()

            if created.length == Object.keys(req.files).length
              res.end JSON.stringify(created)
  download: (req, res, next) ->
    url = req.body.url
    filename = req.body.filename
    profile = req.body.profile

    filePath = path.join(Config.tmpDir, filename)
    download url, filePath, ->
      File.create filePath, filename, profile, (file)->
        res.end JSON.stringify(file.json())
  finish: (req, res, next) ->
    id = req.params.fileId
    format = req.params.format

    notification = req.body

    File.fetch id, format, (file)=>
      if transcoder = file.profile().transcoder(format)
        transcoder.finish file, notification, format, ->
          res.end JSON.stringify(file.json())
      else
        res.end new Error("No transcoder")
  status: (req, res, next) ->
    id = req.params.fileId
    format = req.params.format

    File.fetch id, format, (file)=>
      res.send(file.json())
  delete: (req, res, next) ->
    id = req.params.fileId

    File.delete id, (file)=>
      res.end("ok")


module.exports = FileController
