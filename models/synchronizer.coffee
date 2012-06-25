request = require 'request'
Config = require '../config'

class Synchronizer
  @sync: (file, urls)=>
    console.log "Syncing file #{file.filename()} to #{urls}"
    for url in urls
      console.log "Syncing file #{file.filename()} to #{url}"

      request headers: {'X-Vault-Key': Config.systemKey }, method: 'POST', url: url + 'sync', json: file.json(), (err,response,body)=>
        if err
          console.error err

module.exports = Synchronizer
