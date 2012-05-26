fs = require 'fs'
gm = require 'gm'
CropFilter = require '../../models/crop-filter'
File = require '../../models/file'

module.exports =
  'Set Up': (test)=>
    fs.copyFileSync "./test/data/han.jpg", "/tmp/han.jpg"
    File.create "/tmp/han.jpg", "han.jpg", null, (_file)=>
      @file = _file
      test.ok @file, "File wasn't created"
      test.done()
  'Crop Image': (test)=>
    crop = new CropFilter 'thumb', w: 100, h: 100
    crop.filter @file, =>
      fs.stat @file.join('han.thumb.jpg'), (err, stat)=>
        test.ifError err
        gm(@file.path('thumb')).size (err, value)=>
          test.ifError err
          test.equal 100, value.width
          test.equal 99, value.height
          test.done()

