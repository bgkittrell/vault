fs = require 'fs'
module.exports = (file, cb)->
  fs.writeFile file, null, (err)=>
    throw new Error(err) if err
    cb.call() if cb
