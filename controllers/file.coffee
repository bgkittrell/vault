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
    type = req.params.fileType
    try
      File.fetch id, type, (file)=>
        stat = fs.statSync(file.path(type))
        res.writeHead 200,
          'Content-Type': mime.lookup(file.filename(type)),
          'Content-Length': stat.size
        
        read = fs.createReadStream file.path(type)
        util.pump read, res
    catch error
      console.error error
      res.send(404)

   upload: (req, res, next) ->
    console.log "Uploading"
    try
      created = []
      for key, upload of req.files
        do (key, upload) =>
          File.create upload.name, (file)->
            fs.rename upload.path, file.path()

            created.push file.json()

            if created.length == Object.keys(req.files).length
              res.end JSON.stringify(created)
    catch error
      console.error error
      res.send(500)
  download: (req, res, next) ->
    try
      console.log "Downloading"

      url = req.body.url
      filename = req.body.filename

      filePath = path.join(Config.tmpDir, filename)
      rest.get(url, { encoding: 'binary' }).on 'complete', (data, response)=>
        fs.writeFile filePath, response.raw, (err)=>
          throw new Error(err) if err

          File.create filename, (file)=>
            console.log "Downloading %s", url

            fs.rename filePath, file.path()
            res.end JSON.stringify(file.json())
    catch error
      console.error error
      res.send(500)
  update: (req, res, next) ->
    try
      console.log "Updating"
      id = req.params.fileId
      type = req.params.fileType

      notification = req.body

      File.fetch id, type, (file)=>
        console.log "Downloading %s", notification.output.url
        file.complete type, notification, ()->
          res.end JSON.stringify(file.json())
    catch error
      console.error error
      res.send(500)
  status: (req, res, next) ->
    try
      console.log "Getting Status"
      id = req.params.fileId
      type = req.params.fileType

      File.fetch id, type, (file)=>
        res.send(file.json())
    catch error
      console.error error
      res.send(500)


module.exports = FileController
