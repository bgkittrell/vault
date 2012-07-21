app = require '../../server'
fs = require 'fs'
url = require 'url'
client = require '../../util/http-client'

Secure = require '../../secure'
Config = require '../../config'

serverUrl = Secure.systemUrl(url.format(protocol: Config.serverProtocol, hostname: app.address().address, port: app.address().port, pathname: '/'))

module.exports =
  testVideoUpload: (test)->
    videoFile = './test/data/waves.mov'

    client.upload serverUrl, videoFile, (err, files)=>
        video = files[0]

        checkStatus = ->
          client.json serverUrl + video.id + '.status', (err, status)->
              if status.status is 'finished'
                test.ok true
                test.done()
                return
              else if status.status is 'failed'
                test.ok false, "Video failed to render"
                return
              
              console.log "No status yet, trying again in 5sec"
              setTimeout(checkStatus, 5000)
        checkStatus()
