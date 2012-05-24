fs = require 'fs'
http = require 'http'
url = require 'url'

download = (downloadUrl, path, cb)->
  uri = url.parse(downloadUrl)
  options =
    host: uri.hostname
    port: uri.port || 80
    path: uri.pathname + (uri.search || '')

  file = fs.createWriteStream(path)
  req = http.get options, (res)->
    if res.statusCode in [302, 301, 303, 307]
      download(url.resolve(downloadUrl, res.headers['location']), path, cb)
    else
      res.on 'end', ()->
        file.end()
        cb.call()
      res.on 'data', (data)->
        file.write(data)

  req.on 'error', (e)->
    console.log e

module.exports = download
