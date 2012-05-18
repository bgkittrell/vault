fs = require 'fs'
module.exports =
  touch: (file, cb)->
    console.log "Touching: #{file}"
    fs.writeFile file, null, (err)=>
      throw new Error(err) if err
      console.log "Calling: #{cb}"
      cb.call() if cb
