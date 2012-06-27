fs = require 'fs'
rest = require 'restler'

class Rest
  @get: (url, callbacks)->
    rest.get(url).on('success', (data, response)->
      callbacks.success(data, response) if callbacks.success
    ).on('fail', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    ).on('error', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    )
  @post: (url, params, callbacks)->
    rest.post(url, data: params).on('success', (data, response)->
      callbacks.success(data, response) if callbacks.success
    ).on('fail', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    ).on('error', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    )
  @upload: (url, files, post = {}, callbacks)->
    unless callbacks
      callbacks = arguments[arguments.length - 1]
      post = {}

    count = 1
    for file in files
      size = fs.statSync(file).size
      post["upload#{count++}"] = rest.file(file, null, size)

    rest.post(url, multipart: true, data: post).on('success', (data, response)->
      callbacks.success(JSON.parse(data)) if callbacks.success
    ).on('fail', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    ).on('error', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    )
  @postJson: (url, json, callbacks)->
    data = []
    rest.postJson(url, json).on('success', (data, response)->
      file = JSON.parse(data)
      callbacks.success(file, response) if callbacks.success
    ).on('fail', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
    ).on('error', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
    )
  @delete: (url, callbacks)->
    rest.del(url).on('success', (data, response)->
      callbacks.success(data, response) if callbacks.success
    ).on('fail', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    ).on('error', (error, response)->
      console.error error
      callbacks.failure(response) if callbacks.failure
    )
 module.exports = Rest
