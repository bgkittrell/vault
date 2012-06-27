fs = require 'fs'
request = require 'request'


download = (downloadUrl, path, cb)->
  request(downloadUrl, cb).pipe(fs.createWriteStream(path))

module.exports = download
