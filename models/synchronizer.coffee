request = require 'request'
Config = require '../config'

class Synchronizer
  @sync: (file, urls, format = null)=>
    console.log "Syncing file #{file.filename()} to #{urls}"
    for url in urls
      json =
        id: file.id
        url: Config.serverUrl() + file.id
        filename: file.filename(format).replace /\.original/, ''
        profile: file.profile().name
        format: format
        meta: file.meta()

      console.log "Syncing file #{file.filename()} to #{url}"

      request method: 'POST', url: url, json: json, (err,response,body)=>
        if err
          console.error err

module.exports = Synchronizer
