fs = require 'fs'
aparser = require 'aparser'
request = require 'request'
async = require 'async'

options = {}
aparser.on '--vault-url', (arg, index)->
  options.url = arg

aparser.on '--import-file', (arg, index)->
  options.importFile = arg

aparser.on '--export-file', (arg, index)->
  options.exportFile = arg

aparser.parse(process.argv)

output = fs.createWriteStream options.exportFile

output.once 'open', (fd)->
  console.log "File open for writing"
  fs.readFile options.importFile, (err, data)->
    throw err if err
    console.log "Reading file: %s", options.importFile
    lines = data.toString().split /\n/
    importFile = (line, callback)->
      console.log line
      [url, id] = line.split /,\s*/
      console.log "Importing file: %s", id
      request.post options.url, json: { url: url }, (requestErr, response, file)->
        throw err if err
        console.log "Imported file: %s", file.id
        output.write line + ',' + file.id + '\n'
        callback()

    async.forEachSeries lines, importFile, ()->
      console.log "Import Complete"

