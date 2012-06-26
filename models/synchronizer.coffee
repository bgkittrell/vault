request = require 'request'
Config = require '../config'
Secure = require '../secure'

class Synchronizer
  @sync: (file, urls)=>
    console.log "Syncing file #{file.filename()} to #{urls}"
    for url in urls
      console.log "Syncing file #{file.filename()} to #{url}"

      request method: 'POST', url: Secure.systemUrl(url + 'sync'), json: file.json(), (err,response,body)=>
        if err
          console.error err

module.exports = Synchronizer
