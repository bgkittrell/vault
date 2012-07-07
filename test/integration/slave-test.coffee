fs = require 'fs'
request = require 'request'
rest = require '../rest'
exec  = require('child_process').exec
File = require '../../models/file'
Config = require '../../config'
Secure = require '../../secure'

server1 = exec 'coffee app.coffee'
serverUrl1 = "http://#{Config.serverHost}:#{Config.serverPort}/"
masterUrl = "http://#{Config.serverHost}:#{Config.serverPort}/"
console.log "Testing with URL1: %s", serverUrl1
server1.stdout.on 'data', (data)->
  console.log("[Server 1 : out] #{data}")
server1.stderr.on 'data', (data)->
  console.log("[Server 1 : err] #{data}")

server2 = exec "coffee app.coffee --port #{Config.serverPort + 1} --tmp-dir /tmp/uploads2 --media-dir /tmp/media2 --master-url #{serverUrl1}"
serverUrl2 = "http://#{Config.serverHost}:#{Config.serverPort + 1}/"
console.log "Testing with URL2: %s", serverUrl2
server2.stdout.on 'data', (data)->
  console.log("[Server 2 : out] #{data}")
server2.stderr.on 'data', (data)->
  console.log("[Server 2 : err] #{data}")

server3 = exec "coffee app.coffee --port #{Config.serverPort + 2} --tmp-dir /tmp/uploads3 --media-dir /tmp/media3 --master-url #{serverUrl1}"
serverUrl3 = "http://#{Config.serverHost}:#{Config.serverPort + 2}/"
console.log "Testing with URL3: %s", serverUrl3
server3.stdout.on 'data', (data)->
  console.log("[Server 3 : out] #{data}")
server3.stderr.on 'data', (data)->
  console.log("[Server 3 : err] #{data}")

module.exports =
  testAutoRegister: (test)->
    # Wait for auto register
    setTimeout ->
      request.get Secure.systemUrl(serverUrl1 + 'registry'),  (err, response, body)=>
        test.ifError err
        registry = JSON.parse body
        test.equal response.headers['content-type'], 'application/json'
        test.equal masterUrl, registry.master
        test.equal 2, registry.slaves.length
        test.ok serverUrl2 in registry.slaves
        test.ok serverUrl3 in registry.slaves
        test.done()
    , 5000

  testRegistrySyncSlave1: (test)->
    request.get Secure.systemUrl(serverUrl2 + 'registry'),  (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.equal masterUrl, registry.master
      test.equal 2, registry.slaves.length
      test.ok serverUrl2 in registry.slaves
      test.ok serverUrl3 in registry.slaves
      test.done()

  testRegistrySyncSlave2: (test)->
    request.get Secure.systemUrl(serverUrl3 + 'registry'),  (err, response, body)=>
      test.ifError err
      registry = JSON.parse body
      test.equal response.headers['content-type'], 'application/json'
      test.equal masterUrl, registry.master
      test.equal 2, registry.slaves.length
      test.ok serverUrl2 in registry.slaves
      test.ok serverUrl3 in registry.slaves
      test.done()
  testUploadToSlave: (test)->
    rest.upload Secure.systemUrl(serverUrl2),
      ['./test/data/file.txt'],
      success: (files)=>
        findFile = ->
          file = files[0]
          path1 = File.directory(file.id).replace /media/, 'media2'
          path2 = File.directory(file.id)
          contents = fs.readdirSync(path1)
          console.log "Comparing contents of #{path1} and #{path2}"
          fs.readdir path2, (err, slaveContents)=>
            console.log "Slave contents"
            console.log slaveContents
            console.log "Contents"
            console.log contents
            if slaveContents && contents.length > 1 and contents.length is slaveContents.length
              stat1 = fs.statSync path1 + '/file.original.txt'
              stat2 = fs.statSync path2 + '/file.original.txt'
              console.log "size: %s", stat1.size
              test.equal stat1.size, stat2.size
              test.deepEqual contents, slaveContents
              test.done()
            else
              console.log "File not found, will try again in 3 secs"
              setTimeout findFile, 3000
        findFile()

  testFileSync: (test)->
    rest.upload Secure.systemUrl(serverUrl1),
      ['./test/data/waves.mov'],
      success: (files)=>
        findFile = ->
          file = files[0]
          contents = fs.readdirSync(File.directory(file.id))
          path = File.directory(file.id).replace /media/, 'media2'
          console.log "Comparing contents of #{path}"
          File.fetch file.id, (f)=>
            fs.readdir path, (err, slaveContents)=>
              console.log "Slave contents"
              console.log slaveContents
              console.log "Contents"
              console.log contents
              console.log "Status: %s", f.status()
              if f.status() == 'finished' && slaveContents && contents.length > 7 and contents.length is slaveContents.length
                test.deepEqual contents, slaveContents
                test.done()
              else
                console.log "File not found, will try again in 3 secs"
                setTimeout findFile, 3000
        findFile()

  testReset: (test)->
    request.put Secure.systemUrl(serverUrl1 + 'registry'), json: { master: masterUrl }, (err, response, registry)=>
        test.equal response.headers['content-type'], 'application/json'
        test.equal masterUrl, registry.master
        test.equal 0, registry.slaves.length
        server1.kill()
        server2.kill()
        server3.kill()
        test.done()
