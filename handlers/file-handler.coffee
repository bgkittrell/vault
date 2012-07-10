ime = require 'mime'
uuid = require 'node-uuid'
fs = require 'fs'
util = require 'util'
path = require 'path'
mime = require 'mime'
client = require '../util/http-client'

File = require '../models/file'
Config = require '../config'
Secure = require '../secure'

module.exports = (app)->
  methods = init(app)
  app.param 'fileId', (req, res, next, fileId)->
    unless fileId.match /^\w+\-\w+\-\w+\-\w+\-\w+$/
      res.statusCode = 404
      return res.end()
    File.fetch fileId, (file)->
      if file
        req.locals.file = file
        next()
      else
        res.statusCode = 404
        res.end()

  app.get '/secure/:auth/:fileId.status', Secure.read, methods.status
  app.get '/secure/:auth/:format/:fileId/:options', Secure.read, methods.serve
  app.get '/secure/:auth/:format/:fileId', Secure.read, methods.serve
  app.get '/secure/:auth/:fileId', Secure.read,  methods.serve

  app.get '/:fileId.status', Secure.read, methods.status
  app.get '/:format/:fileId/:options', Secure.read, methods.serve
  app.get '/:format/:fileId', Secure.read, methods.serve
  app.get '/:fileId', Secure.read,  methods.serve

  app.post '/secure/:auth/:format/:fileId', Secure.update, methods.finish
  app.post '/secure/:auth', Secure.create, (req,res,next)->
    if req.files
      methods.upload(req, res, next)
    else
      methods.download(req, res, next)
  app.delete '/secure/:auth/:fileId', Secure.delete, methods.delete
  app.post '/', Secure.create, (req,res,next)->
    methods.upload(req, res, next)

sync = (file, registry)=>
    json = file.json()
    json.sourceUrl = Config.serverUrl()
    for url in registry.others()
      client.postJson Secure.systemUrl(url + 'sync'), json, (err)=>
        if err
          console.error err

init = (app)->
  serve: (req, res, next) =>
    id = req.params.fileId
    format = req.params.format
    if req.params.options
      options = JSON.parse("{" + req.params.options.replace(/(\w+):/g, '"$1":') + "}")

    req.locals.file.filter format, options, (filePath)=>
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
  upload: (req, res, next) =>
    created = []

    for key, upload of req.files
      do (key, upload) =>
        if upload.name
          File.create upload.path, upload.name, profile: req.param('profile'), public: req.param('public'), (file)=>
            created.push file.json()

            if created.length == Object.keys(req.files).length
              res.end JSON.stringify(created)
            file.profile().transcode file
            sync file, app.registry
  download: (req, res, next) =>
    params = req.body

    filePath = path.join(Config.tmpDir, params.filename || uuid.v4())
    client.download params.url, filePath, (err, downloadResponse)=>
      filename = params.filename || "file.#{mime.extension(downloadResponse.headers['content-type'])}"
      File.create filePath, filename, profile: params.profile, (file)=>
        res.end JSON.stringify(file.json())
        file.profile().transcode file
        sync file, app.registry
  finish: (req, res, next) =>
    file = req.locals.file
    format = req.params.format

    notification = req.body

    if transcoder = file.profile().transcoder(format)
      transcoder.finish file, notification, format, =>
        res.end JSON.stringify(file.json())
        sync file, app.registry
    else
      res.end new Error("No transcoder")
  status: (req, res, next) =>
    file = req.locals.file
    format = req.params.format

    res.send(file.json())
  delete: (req, res, next) =>
    file = req.locals.file

    file.delete (file)=>
      res.end("ok")
