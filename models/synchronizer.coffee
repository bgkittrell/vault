request = require 'request'
Config = require '../config'
Secure = require '../secure'

class Synchronizer
  @sync: (file, registry)=>
    json = file.json()
    json.sourceUrl = Config.serverUrl()
    for url in registry.others()
      request method: 'POST', url: Secure.systemUrl(url + 'sync'), json: json, (err,response,body)=>
        if err
          console.error err

module.exports = Synchronizer
