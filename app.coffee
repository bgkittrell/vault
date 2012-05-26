fs = require 'fs'
express = require 'express'

Config = require './config'

RegistryController = require './controllers/registry'
registryController = new RegistryController()
FileController = require './controllers/file'
fileController = new FileController()

fs.mkdir(Config.mediaDir)
fs.mkdir(Config.deleteDir)

port = Config.serverPort

app = module.exports = express.createServer()
app.use(express.logger())

app.on 'error', (err) ->
  console.log 'there was an error:', err.stack

allowCrossDomain = (req, res, next)->
  res.header('Access-Control-Allow-Origin', 'http://localhost:9001')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  next()

app.configure ()->
  app.use(allowCrossDomain)
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)

app.configure 'development', ()->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ()->
  app.use(express.errorHandler())

app.configure 'test', ()->
  port += 1

app.param 'fileId', (req, res, next, fileId)->
  unless fileId.match /^\w+\-\w+\-\w+\-\w+\-\w+$/
    res.send(404)
    return next("#{fileId} not found")
  next()

app.get '/registry', registryController.get
app.post '/registry', registryController.add
app.put '/registry', registryController.sync

app.get '/:fileId.status', fileController.status
app.get '/:format/:fileId', fileController.serve
app.get '/:fileId', fileController.serve
app.post '/:format/:fileId', fileController.finish
app.post '/', (req,res,next)->
  if req.files
    fileController.upload(req, res, next)
  else
    fileController.download(req, res, next)
app.delete '/:fileId', fileController.delete

app.listen(port)
console.log("Vault server listening on port %d in %s mode", app.address().port, app.settings.env)
