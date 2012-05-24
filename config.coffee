Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: 'localhost'
  serverPort: 7000
  serverProtocol: 'http'
  serverUrl: ->
    "#{Config.serverProtocol}://#{Config.serverHost}:#{Config.serverPort}/"
  imageProfiles:
    thumb:
      crop:
        w: 100
        h: 100
    medium:
      resize:
        w: 200
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
