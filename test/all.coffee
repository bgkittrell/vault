reporter = require('nodeunit').reporters.default
app = require('../app')
reporter.run [
    'test/models/file-test.coffee',
    'test/controllers/serve-file-test.coffee',
    'test/controllers/upload-file-test.coffee',
    'test/controllers/image-upload-test.coffee',
    'test/controllers/video-upload-test.coffee',
    'test/controllers/audio-upload-test.coffee',
    'test/controllers/delete-file-test.coffee',
    'test/controllers/registry-test.coffee',
    'test/controllers/slave-test.coffee'
  ],
  null,
  ()->
    console.log("Complete")
    app.close()
