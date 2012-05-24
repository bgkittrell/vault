fs = require 'fs'
module.exports =
  touch: (file, cb)->
    fs.writeFile file, null, (err)=>
      throw new Error(err) if err
      cb.call() if cb
