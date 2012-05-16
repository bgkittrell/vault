fs = require 'fs'
rest = require 'restler'

class Rest
  @get: (url, callbacks)->
    console.log "Getting %s", url
    rest.get(url).on('success', (data, response)->
      callbacks.success(data, response) if callbacks.success
    ).on('fail', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    ).on('error', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    )
  @post: (url, data, callbacks)->
    console.log "Posting to %s", url
    rest.post(url, data: data).on('success', (data, response)->
      callbacks.success() if callbacks.success
    ).on('fail', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    ).on('error', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    )
  @upload: (url, files, callbacks)->
    post = {}
    count = 1
    for file in files
      size = fs.statSync(file).size
      console.log size
      post["upload#{count++}"] = rest.file(file, null, size)

    console.log "Uploading to %s", url
    rest.post(url, multipart: true, data: post).on('success', (data, response)->
      callbacks.success(JSON.parse(data)) if callbacks.success
      Rest.error() if Rest.error
    ).on('fail', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    ).on('error', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    )
  @postJson: (url, json, callbacks)->
    data = []
    console.log "Posting JSON %s", url
    rest.postJson(url, json).on('success', (data, response)->
      file = JSON.parse(data)
      callbacks.success(file, response) if callbacks.success
    ).on('fail', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    ).on('error', (error)->
      console.error error
      callbacks.failure() if callbacks.failure
      throw new Error(error)
    )

 module.exports = Rest
