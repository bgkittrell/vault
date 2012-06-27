reporter = require('nodeunit').reporters.default
app = require('../app')
reporter.run [
    'test/unit/file-test.coffee',
    'test/unit/resize-filter-test.coffee',
    'test/unit/crop-filter-test.coffee',
    'test/unit/image-meta-test.coffee',
    'test/unit/profile-test.coffee',
    'test/functional/security-test.coffee',
    'test/functional/file-test.coffee',
    'test/functional/image-upload-test.coffee',
    'test/functional/video-upload-test.coffee',
    'test/functional/audio-upload-test.coffee',
    'test/functional/sync-test.coffee',
    'test/functional/registry-test.coffee'
  ],
  null,
  ()->
    console.log("Complete")
    app.close()
