reporter = require('nodeunit').reporters.default
app = require('../app')
reporter.run [
    'test/serve-file-test.coffee',
    'test/upload-file-test.coffee',
    'test/image-upload-test.coffee',
    'test/video-upload-test.coffee',
    'test/audio-upload-test.coffee',
    'test/delete-file-test.coffee',
    'test/registry-test.coffee',
    'test/slave-test.coffee'
  ],
  null,
  ()->
    console.log("Complete")
    app.close()
