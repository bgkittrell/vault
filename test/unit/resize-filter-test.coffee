fs = require 'fs-extra'
gm = require 'gm'
ResizeFilter = require '../../filters/resize-filter'
File = require '../../models/file'

module.exports =
  'Set Up': (test)=>
    fs.copy "./test/data/han.jpg", "/tmp/han.jpg", ()=>
      File.create "/tmp/han.jpg", "han.jpg", null, (_file)=>
        @file = _file
        test.ok @file, "File wasn't created"
        test.done()
  'Resize Image': (test)=>
    resize = new ResizeFilter 'medium', w: 200
      
    resize.filter @file, =>
      fs.stat @file.join('han.medium.jpg'), (err, stat)=>
        test.ifError err
        gm(@file.path('medium')).size (err, value)=>
          test.ifError err
          test.equal 200, value.width
          test.done()

