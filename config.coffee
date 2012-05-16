Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  serverUrl: 'http://64.19.36.226:7000/'
  imageProfiles:
    thumb:
      crop:
        w: 100
        h: 100
    medium:
      resize:
        w: 400
    large:
      resize:
        h: 600
  videoProfiles:
    mobile:
      format: 'mp4'
    archive:
      format: 'ogv'

module.exports = Config
