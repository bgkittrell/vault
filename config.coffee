Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  serverUrl: 'http://98.156.53.253:7000/'
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
    default:
      web:
        encoding:
          size: '480x360'
          format: 'mp4'
      archive:
        async: true
        encoding:
          format: 'ogv'
          quality: 5
          audio_quality: 5
          speed: 5
    stupeflix:
      archive:
        async: true
        encoding:
          format: 'ogv'
          quality: 5
          audio_quality: 5
          speed: 5
    audio:
      mp3:
        encoding:
          format: 'mp3'
          audio_quality: 5
          speed: 5

module.exports = Config
