request = require 'request'
fs = require 'fs'
path = require 'path'
array = require '../util/array'
hash = require '../util/hash'
mime = require 'mime'
util = require 'util'
async = require 'async'
url = require 'url'

Config = require '../config'
Secure = require '../secure'
File = require '../models/file'
Profile = require '../models/profile'

class SyncController
  constructor: (@app)->
  sync: (req, res, next)->
    json = req.body

    sourceUrl = json.sourceUrl
    console.log "Syncing file from source url: %s", sourceUrl

    File.fetch json.id, (file)->
      syncFile = (from, to)->
        profile = new Profile(from.profile, Config.profiles[from.profile])
        for name, format of profile.formats
          do (name, format) ->
            queue = []
            fromFormat = array(from.formats).find (f)-> f.format == name

            if to.status(name) != 'finished' and fromFormat and format.transcoder and fromFormat.status == 'finished'
              filePath = path.join(Config.tmpDir, file.id + file.filename(name))

              queue.push (done)->
                request(Secure.systemUrl(sourceUrl + "#{name}/#{file.id}"), (err, response, body)->
                  if err
                    console.error "Couldn't sync file: %s", json.id
                    console.error err
                  else
                    fs.rename filePath, to.path(name), done
                ).pipe(fs.createWriteStream(filePath))

              thumbnails = hash(format.transcoder).first().thumbnails

              if thumbnails
                thumbPath = path.join(Config.tmpDir, json.id + thumbnails.label)

                queue.push (done)->
                  request(Secure.systemUrl(sourceUrl + "sync/#{json.id}/#{thumbnails.label}.png"),  (err, response, body)->
                    console.error err if err
                    fs.rename thumbPath, to.join("#{thumbnails.label}.png"), done
                  ).pipe(fs.createWriteStream(thumbPath))
                

              if fromFormat.status
                queue.push (done)-> to.set status: "#{fromFormat.status}.#{name}", done
              if fromFormat.duration
                queue.push (done)-> to.set duration: "#{fromFormat.duration}.#{name}", done
              if fromFormat.width and fromFormat.height
                queue.push (done)-> to.set size: "#{fromFormat.width}x#{fromFormat.height}.#{name}", done
              
              async.parallel queue, ()->
                console.log "Finished syncing: #{name}"
      if file
        syncFile json, file
      else
        originalPath = path.join(Config.tmpDir, json.filename)
        request(Secure.systemUrl(sourceUrl + json.id),  (err, response, body)->
          if err
            console.error "Couldn't sync file: %s", json.id
            console.error err
          else
            File.create originalPath, json.filename.replace(/original\./, ''), profile: json.profile, id: json.id, public: json.public, (file)=>
              syncFile json, file
        ).pipe(fs.createWriteStream(originalPath))
      res.end()

  file: (req, res, next)->
    id = req.params.fileId
    filename = req.params.filename

    File.fetch id, (file)=>
      if file
        fs.stat file.join(filename), (err, stat)=>
          if err
            res.send(404)
          else
            res.writeHead 200,
              'Content-Type': mime.lookup(filename)
              'Content-Length': stat.size
            
            read = fs.createReadStream file.join(filename)
            util.pump read, res
      else
        res.status = 404
        res.end()

module.exports = SyncController
