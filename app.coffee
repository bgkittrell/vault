fs = require 'fs'
express = require 'express'

Config = require './config'

FileController = require './controllers/file'
fileController = new FileController(app)

fs.mkdir(Config.mediaDir)

app = module.exports = express.createServer()

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
  app.use(express.logger({ format: ':method :url' }))

app.configure 'development', ()->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', ()->
  app.use(express.errorHandler())

# Routes

app.param 'fileId', (req, res, next, fileId)->
  unless fileId.match /^\w+\-\w+\-\w+\-\w+\-\w+$/
    res.send(404)
    return next("#{fileId} not found")
  next()

app.post '/:fileType/:fileId', fileController.update
app.post '/', (req,res,next)->
  if req.files
    fileController.upload(req, res, next)
  else
    fileController.download(req, res, next)
app.get '/:fileId.status', fileController.status
app.get '/:fileType/:fileId', fileController.serve
app.get '/:fileId', fileController.serve

app.listen(7000)
console.log("Vault server listening on port %d in %s mode", app.address().port, app.settings.env)
