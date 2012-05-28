fs = require 'fs-extra'
gm = require 'gm'
path = require 'path'

Config = require '../../config'
Profile = require '../../models/profile'
File = require '../../models/file'

module.exports =
  'Default Profile': (test)=>
    test.equal Profile.default('han.jpg'), 'image'
    test.equal Profile.default('han.mov'), 'video'
    test.done()
  'Test Filter': (test)=>
    fs.copyFileSync "./test/data/han.jpg", "/tmp/han.jpg"
    File.create "/tmp/han.jpg", "han.jpg", null, (file)=>
      test.ok file, "File wasn't created"

      file.profile().filter file, 'thumb', =>
        test.done()
