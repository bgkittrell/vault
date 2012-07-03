fs = require 'fs'
express = require 'express'
request = require 'request'
aparser = require 'aparser'
http = require 'http'

Config = require './config'
Secure = require './secure'
Registry = require './models/registry'
File = require './models/file'

RegistryController = require './controllers/registry'
FileController = require './controllers/file'
SyncController = require './controllers/sync'

aparser.on '--port', (arg, index)->
  console.log "Overridding default port: #{arg}"
  Config.serverPort = arg

aparser.on '--media-dir', (arg, index)->
  console.log "Overridding default media direcory: #{arg}"
  Config.mediaDir = arg

aparser.on '--tmp-dir', (arg, index)->
  console.log "Overridding default tmp direcory: #{arg}"
  Config.tmpDir = arg

aparser.on '--master-url', (arg, index)->
  console.log "Overridding default master url"
  Config.masterUrl = arg

aparser.parse(process.argv)

fs.mkdir(Config.mediaDir)
fs.mkdir(Config.tmpDir)
fs.mkdir(Config.deleteDir)

port = Config.serverPort

app = express()
app.use(express.logger())

app.on 'error', (err) ->
  console.log 'there was an error:', err.stack

allowCrossDomain = (req, res, next)->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Authorization')
  res.header('Access-Control-Allow-Credentials', 'true')
  if req.method == 'OPTIONS'
    res.statusCode = 200
    res.end()
  else
    next()

app.configure ()->
  app.use(allowCrossDomain)
  app.use(Secure.load())
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
    res.statusCode = 404
    return res.end()
  File.fetch fileId, (file)->
    if file
      req.file = file
    else
      res.statusCode = 404
      return res.end()
  next()

if Config.masterUrl
  console.log "Initializing slave %s with master: %s", Config.serverUrl(), Config.masterUrl
  data = slaveUrl: Config.serverUrl()
  request.post
    url: Secure.systemUrl(Config.masterUrl + 'registry'), json: data, (err,response,body)=>
      if err
        throw new Error(err)
      if response.statusCode == 200
        app.registry = new Registry(body.master, body.slaves, body.writeable)
        console.log "Successfully registered with master: URL %s", Config.masterUrl
      else
        console.error "Couldn't register with master: URL %s", Config.masterUrl
else
  console.log "Initializing registry as master: URL %s", Config.serverUrl()
  app.registry = new Registry(Config.serverUrl())

registryController = new RegistryController(app)
fileController = new FileController(app)
syncController = new SyncController(app)

app.get '/registry', Secure.read,  registryController.get
app.post '/registry', Secure.system,  registryController.add
app.put '/registry', Secure.system,  registryController.sync

app.post '/sync', Secure.system,  syncController.sync
app.get '/sync/:fileId/:filename', Secure.system,  syncController.file

app.get '/:fileId.status', Secure.read, fileController.status
app.get '/:format/:fileId/:options', Secure.read, fileController.serve
app.get '/:format/:fileId', Secure.read, fileController.serve
app.get '/:fileId', Secure.read,  fileController.serve
app.post '/:format/:fileId', Secure.update, fileController.finish
app.post '/', Secure.create, (req,res,next)->
  if req.files
    fileController.upload(req, res, next)
  else
    fileController.download(req, res, next)
app.delete '/:fileId', Secure.delete, fileController.delete

server = http.createServer(app).listen(port)

app.close = ()->
  server.close()
app.address = ()->
  server.address()

module.exports = app

console.log("Vault server listening on port %d in %s mode", port, app.settings.env)
