fs = require 'fs'
request = require 'request'
http = require 'http'
mime = require 'mime'

module.exports =
  get: (url, callback)->
    request.get url, (err, response, data)->
      callback(err, data, response)
  json: ([url, params]..., callback)->
    request.get url, qs: params, (err, response, data)->
      if response.statusCode == 200
        callback(err, JSON.parse(data), response)
      else
        callback(err, null, response)
  upload: ([url, file, post]..., callback)->
    fs.readFile file, (err, buffer)->
      request.post(url: url, qs: post, multipart: [encodeFile(buffer, file)], headers: { 'content-type': 'multipart/form-data' }, (err, response, data)->
        if response.statusCode == 200
          callback(err, JSON.parse(data), response)
        else
          callback(err, null, response)
      )
  download: (downloadUrl, path, cb)->
    request(downloadUrl, cb).pipe(fs.createWriteStream(path))

  delete: (url, callback)->
    request.del url, callback
  put: (url, callback)->
    request.put url, (err, response, data)->
      callback(err, data, response)
  putJson: (url, json, callback)->
    request.put url, json: json, (err, response, data)->
      callback(err, data, response)
  post: (url, callback)->
    request.post url, (err, response, data)->
      callback(err, data, response)
  postJson: (url, json, callback)->
    request.post url, json: json, (err, response, data)->
      callback(err, data, response)

encodeFile = (buffer, filename)->
  "Content-Disposition": "form-data; name=\"upload1\"; filename=\"" + filename.replace(/.*\/([^\/]+)$/, '$1') + '"'
  "Content-Type": "#{mime.lookup(filename)}"
  body: buffer
