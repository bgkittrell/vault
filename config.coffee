Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: 'localhost'
  serverPort: 7000
  serverProtocol: 'http'
  serverUrl: ->
    "#{Config.serverProtocol}://#{Config.serverHost}:#{Config.serverPort}/"
  filterNames: ['crop']
  profiles:
    'image':
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff']
      'thumb':
        filter:
          crop:
            w: 100
            h: 100
      'medium':
        filter:
          resize:
            w: 200
      'large':
        filter:
          resize:
            h: 600
    'video':
      extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
      'web':
        transcode:
          encoding:
            size: '480x360'
            format: 'mp4'
      'archive':
        transcode:
          async: true
          encoding:
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
    'stupeflix':
      'archive':
        transcode:
          encoding:
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
    'audio':
      'mp3':
        transcode:
          encoding:
            format: 'mp3'
            audio_quality: 5
            speed: 5

module.exports = Config

Config.filters = {}
for name in Config.filterNames
  Config.filters[name] = require "./models/#{name}-filter"
