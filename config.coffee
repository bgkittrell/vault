Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: '98.156.53.253'
  serverPort: 7000
  serverProtocol: 'http'
  systemKey: 'Bh8XJhRVED4zLgWQyW'
  apiKey: 'ih8XJhRnE34zLg3QiW'
  appKey: 'h8XJhRnE34zLg3Qi8'
  remoteAuthUrl: 'http://localhost:9001/auth/file'
  zencoderKey: '1e8ef8591b769f1a4b153c2819b7e6e2'
  serverUrl: ->
    "#{Config.serverProtocol}://#{Config.serverHost}:#{Config.serverPort}/"

Config.production =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: '@VAULT_HOST@'
  serverPort: '@VAULT_PORT@'
  serverProtocol: 'http'
  systemKey: '@VAULT_SYSTEM_KEY@'
  apiKey: '@VAULT_API_KEY@'
  appKey: '@VAULT_APP_KEY@'
  remoteAuthUrl: '@VAULT_REMOTE_AUTH_URL@'
  zencoderKey: '@VAULT_ZENCODER_KEY@'

Config.profiles =
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
          'Zencoder':
            size: '480x360'
            format: 'mp4'
      'archive':
        transcoder:
          'Zencoder':
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
            thumbnails:
              label: 'poster'
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
          'Zencoder':
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
    'audio':
      'mp3':
        transcoder:
          'Zencoder':
            format: 'mp3'
            audio_quality: 5
            speed: 5

module.exports = Config

