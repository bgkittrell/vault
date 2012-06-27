request = require 'request'
Config = require '../config'
Secure = require '../secure'

class Synchronizer
  @sync: (file, urls)=>
    for url in urls
      request method: 'POST', url: Secure.systemUrl(url + 'sync'), json: file.json(), (err,response,body)=>
        if err
          console.error err

module.exports = Synchronizer
