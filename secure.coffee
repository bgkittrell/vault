express = require 'express'
Config = require './config'

class Secure
  @systemAuth: express.basicAuth (username, password)->
    Secure.checkCreds username, password,
      system: Config.systemKey
  @readAuth: express.basicAuth (username, password)->
    Secure.checkCreds username, password,
      app: Config.appKey
      api: Config.apiKey
  @writeAuth: express.basicAuth (username, password)->
    Secure.checkCreds username, password,
      app: Config.appKey
  @checkCreds: (username, password, creds)->
    return true if username is key and password is value for key, value of creds
    return false
  @apiUrl: (url)->
    @secureUrl url, 'api', Config.apiKey
  @systemUrl: (url)->
    if url
      @secureUrl url, 'system', Config.systemKey
    else
      @systemUrl(Config.serverUrl())
  @secureUrl: (url, username, password)->
    url.replace /:\/\//, "://#{username}:#{password}@"

module.exports = Secure
