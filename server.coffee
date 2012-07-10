fs = require 'fs'
express = require 'express'
aparser = require 'aparser'
http = require 'http'

Config = require './config'

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
  res.header('Access-Control-Allow-Headers', 'content-type')
  if req.method == 'OPTIONS'
    res.statusCode = 200
    res.end()
  else
    next()

app.configure ()->
  app.use (req, res, next)->
    req.locals ||= {}
    next()
  app.use(allowCrossDomain)
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)

app.configure 'production', ()->
  console.log "Production mode"
  app.use(express.errorHandler())
  for key, value of Config.production
    Config[key] = value

app.get '/crossdomain.xml', (req, res, next)=>
  res.end '<?xml version="1.0"?>\n
      <cross-domain-policy>\n
        <site-control permitted-cross-domain-policies="all"/>\n
        <allow-access-from domain="*" to-ports="*"/>\n
      </cross-domain-policy\n'

(require './handlers/registry-handler')(app)
(require './handlers/sync-handler')(app)
(require './handlers/file-handler')(app)

server = http.createServer(app).listen(port)

app.close = ()->
  server.close()
app.address = ()->
  server.address()

module.exports = app

console.log("Vault server listening on port %d in %s mode", port, app.settings.env)
