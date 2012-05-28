Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: 'localhost'
  serverPort: 7000
  serverProtocol: 'http'
  serverUrl: ->
    "#{Config.serverProtocol}://#{Config.serverHost}:#{Config.serverPort}/"
  zencoderKey: '1e8ef8591b769f1a4b153c2819b7e6e2'
  profiles:
    'image':
      metaFilter: 'ImageMeta'
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff']
      'thumb':
        filter:
          'CropFilter':
            w: 100
            h: 100
      'medium':
        filter:
          'ResizeFilter':
            w: 200
      'large':
        filter:
          'ResizeFilter':
            h: 600
    'video':
      extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
      'web':
        transcoder:
          'VideoTranscoder':
            size: '480x360'
            format: 'mp4'
      'archive':
        transcoder:
          'VideoTranscoder':
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
      'thumb':
        filter:
          'CropFilter':
            file: 'poster.png'
            w: 100
            h: 100
      'poster':
        filter:
          'ResizeFilter':
            file: 'poster.png'
            w: 200
    'stupeflix':
      'archive':
        transcoder:
          'VideoTranscoder':
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
    'audio':
      'mp3':
        transcoder:
          'VideoTranscoder':
            format: 'mp3'
            audio_quality: 5
            speed: 5

module.exports = Config

