fs = require 'fs'
gm = require 'gm'
File = require '../../models/file'

module.exports =
  'Test Meta': (test)=>
    fs.copyFileSync "./test/data/han.jpg", "/tmp/han.jpg"
    File.create "/tmp/han.jpg", "han.jpg", null, (_file)=>
      @file = _file
      test.deepEqual @file.values('size'), [1024, 770]
      test.done()
