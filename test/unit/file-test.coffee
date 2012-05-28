fs = require 'fs-extra'
gm = require 'gm'
path = require 'path'

VideoTranscoder = require '../../models/video-transcoder'

VideoTranscoder.prototype.start = (file)->
  console.log "Bypassing Zencoder"

Config = require '../../config'
File = require '../../models/file'

standardFileTests = (filename)->
  'Set Up': (test)->
    fs.copyFileSync "./test/data/#{filename}", "/tmp/#{filename}"
    test.done()
  'Create File': (test)=>
    File.create "/tmp/#{filename}", filename, null, (_file)=>
      @file = _file
      test.ok @file, "File wasn't created"
      test.ok @file.id.match /[\w-]{36}/, "File id is invalid"
      test.done()
  'Fetch File': (test)=>
    File.fetch @file.id, null, (_file)=>
      @file = _file
      test.equal _file.id, @file.id
      test.equal _file.filename(), @file.filename()
      test.done()
  'Check Metadata': (test)=>
    parts = filename.split('.')
    test.equal @file.filename(), parts[0] + '.original.' + parts[1]
    test.equal @file.extension(), parts[1]
    test.equal @file.prefix(), parts[0]
    test.equal @file.join('somecrap'), path.join(@file.directory(), 'somecrap')
    test.equal @file.path(), path.join(@file.directory(), @file.filename())
    test.done()
  'Set Metadata': (test)=>
    @file.set status: 'finished', =>
      fs.stat @file.join('finished.status'), (err, stat)=>
        test.ifError err, "There was an error setting the status"
        test.equal @file.get('status'), 'finished'
        test.ok @file.get 'status'
        test.done()
  'Change Format': (test)=>
    parts = filename.split('.')
    fn = @file.rename 'web'
    test.ok fn.match parts[0] + '.web.'
    test.done()
  'JSON': (test)=>
    json = file.json()
    parts = filename.split('.')
    test.equal json.filename, parts[0] + '.original.' + parts[1]
    test.equal json.id, file.id
    test.done()

module.exports =
  'Standard File Suite': standardFileTests('file.txt')
  'Standard Image Suite': standardFileTests('han.jpg')
  'Standard Video Suite': standardFileTests('waves.mov')
  'Standard Audio Suite': standardFileTests('audio.flv')
  'Static Methods': (test)=>
    id = 'af9ahewf08hwfhaf'
    test.equal File.directory(id), path.join(Config.mediaDir, 'af', '9a', id)
    test.done()
  'Video Suite':
    'Set Up': (test)->
      fs.copyFileSync "./test/data/waves.mov", "/tmp/waves.mov"
      test.done()
    'Create File With Profile': (test)=>
      File.create '/tmp/waves.mov', 'waves.mov', 'stupeflix', (_file)=>
        @file = _file
        test.ok @file, "File wasn't created"
        test.ok @file.id.match /[\w-]{36}/, "File id is invalid"
        console.log @file.profile()
        test.equal @file.profile().name, 'stupeflix'
        test.ok @file instanceof File, "File should be an instance of File"
        test.done()
    'Change Format': (test)=>
      test.equal @file.filename('archive'), 'waves.archive.ogv'
      test.equal @file.extension('archive'), 'ogv'
      test.done()
    'Metadata': (test)=>
      @file.set duration: 1000
      @file.set size: '480x360'
      @file.set status: 'finished'
      test.equals @file.get('duration'), 1000
      test.deepEqual @file.values('size'), [480, 360]
      test.equals @file.get('status'), 'finished'
      test.done()
    'JSON': (test)=>
      json = @file.json()
      test.equals json.duration, 1000
      test.equals json.width, 480
      test.equals json.height, 360
      test.equals json.status, 'finished'
      test.done()
  'Image Suite':
    'Set Up': (test)->
      fs.copyFileSync "./test/data/han.jpg", "/tmp/han.jpg"
      test.done()
    'Create File With Profile': (test)=>
      File.create '/tmp/han.jpg', 'han.jpg', null, (_file)=>
        @file = _file
        test.ok @file, "File wasn't created"
        test.ok @file.id.match /[\w-]{36}/, "File id is invalid"
        test.equal @file.profile().name, 'image'
        test.ok @file instanceof File, "File should be an instance of File"
        test.done()
    'Change Format': (test)=>
      test.equal @file.filename('thumb'), 'han.thumb.jpg'
      test.equal @file.extension('thumb'), 'jpg'
      test.done()
    'Fetch With Format': (test)=>
      File.fetch @file.id, null, (_file)=>
        test.ifError @file.findFormat('thumb'), "Shouldn't have thumbnail"
      File.fetch @file.id, 'thumb', (_file)=>
        @file = _file
        test.ok @file.findFormat('thumb'), "Should have thumbnail"
        fs.stat @file.join('han.thumb.jpg'), (err, stat)=>
          test.ifError err
          gm(@file.path('thumb')).size (err, value)=>
            test.ifError err
            test.equal 100, value.width
            test.equal 99, value.height
            test.done()
