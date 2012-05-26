ImageMeta = require './models/image-meta'
CropFilter = require './models/crop-filter'
ResizeFilter = require './models/resize-filter'
Zencoder = require './models/zencoder'

Config =
  mediaDir: '/tmp/media'
  tmpDir: '/tmp/'
  deleteDir: '/tmp/delete'
  serverHost: '98.156.53.253'
  serverPort: 7000
  serverProtocol: 'http'
  serverUrl: ->
    "#{Config.serverProtocol}://#{Config.serverHost}:#{Config.serverPort}/"
  zencoderKey: '1e8ef8591b769f1a4b153c2819b7e6e2'
  profiles:
    'image':
      metaFilter: new ImageMeta
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff']
      'thumb':
        filter:
          new CropFilter 'thumb'
            w: 100
            h: 100
      'medium':
        filter:
          new ResizeFilter 'medium'
            w: 200
      'large':
        filter:
          new ResizeFilter 'large'
            h: 600
    'video':
      extensions: ['mov', 'avi', 'ogv', 'mp4', 'm4v', 'mkv', 'flv']
      'web':
        transcoder:
          new Zencoder 'web',
            encoding:
              size: '480x360'
              format: 'mp4'
      'archive':
        async: true
        transcoder:
          new Zencoder 'archive',
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
      'thumb':
        filter:
          new CropFilter 'thumb'
            file: 'poster.png'
            w: 100
            h: 100
      'poster':
        filter:
          new ResizeFilter 'large'
            file: 'poster.png'
            w: 200
    'stupeflix':
      'archive':
        transcoder:
          new Zencoder 'archive',
            format: 'ogv'
            quality: 5
            audio_quality: 5
            speed: 5
    'audio':
      'mp3':
        transcoder:
          new Zencoder 'mp3',
            format: 'mp3'
            audio_quality: 5
            speed: 5

module.exports = Config

