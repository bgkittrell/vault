reporter = require('nodeunit').reporters.default
app = require('../app')
reporter.run [
    'test/upload-file-test.coffee',
    'test/image-upload-test.coffee',
    'test/video-upload-test.coffee',
    'test/serve-file-test.coffee'
  ],
  null,
  ()->
    console.log("Complete")
    app.close()
