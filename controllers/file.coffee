mime = require 'mime'
fs = require 'fs'
util = require 'util'
path = require 'path'
rest = require 'restler'

File = require '../models/file'
Config = require '../config'

class FileController
  serve: (req, res, next) ->
    console.log "Serving"
    id = req.params.fileId
    format = req.params.format
    console.log id
    console.log format

    File.fetch id, format, (file)=>
      stat = fs.statSync(file.path(format))
      res.writeHead 200,
        'Content-Type': mime.lookup(file.filename(format)),
        'Content-Length': stat.size
      
      read = fs.createReadStream file.path(format)
      util.pump read, res
   upload: (req, res, next) ->
    console.log "Uploading"
    created = []

    for key, upload of req.files
      do (key, upload) =>
        File.create upload.path, upload.name, req.param('profile'), (file)->
          created.push file.json()

          if created.length == Object.keys(req.files).length
            res.end JSON.stringify(created)
  download: (req, res, next) ->
    console.log "Downloading"

    url = req.body.url
    filename = req.body.filename
    profile = req.body.profile
    console.log req.body

    filePath = path.join(Config.tmpDir, filename)
    rest.get(url, { encoding: 'binary' }).on 'success', (data, response)=>
      fs.writeFile filePath, response.raw, (err)=>
        throw new Error(err) if err

        File.create filePath, filename, profile, (file)=>
          console.log "Downloading %s", url
          res.end JSON.stringify(file.json())
  update: (req, res, next) ->
    console.log "Updating"
    id = req.params.fileId
    format = req.params.format

    notification = req.body

    File.fetch id, format, (file)=>
      console.log "Downloading %s", notification.output.url
      file.complete format, notification, ()->
        res.end JSON.stringify(file.json())
  status: (req, res, next) ->
    console.log "Getting Status"
    id = req.params.fileId
    format = req.params.format

    File.fetch id, format, (file)=>
      res.send(file.json())


module.exports = FileController
