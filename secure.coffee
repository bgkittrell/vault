express = require 'express'
request = require 'request'
Config = require './config'
utils = require('express').utils

class Secure
  @load: ()->
    return express.basicAuth (username, password, callback)->
      if username and password
        callback null, { username: username, password: password }
      else
        callback null
  @system: (req, res, next)->
    if req.user.username is 'system'
      next()
    else
      Secure.unauthorized res
  @read: (req, res, next)->
    authorized =
      system: Config.systemKey
      app: Config.appKey
      api: Config.apiKey
    Secure.authorize req, res, next, authorized
  @update: (req, res, next)->
    authorized =
      system: Config.systemKey
      app: Config.appKey
      api: Config.apiKey
    Secure.authorize req, res, next, authorized
  @create: (req, res, next)->
    authorized =
      system: Config.systemKey
      app: Config.appKey
    Secure.authorize req, res, next, authorized
  @delete: (req, res, next)->
    authorized =
      system: Config.systemKey
      app: Config.appKey
    Secure.authorize req, res, next, authorized
  @authorize: (req, res, next, authorized)->
    if req.user
      if @checkCreds req.user.username, req.user.password, authorized
        next()
      else
        @remoteAuth req, res, next
    else
      @unauthorized()
  @checkCreds: (username, password, creds)->
    for key, value of creds
      return true if username is key and password is value
    return false
  @unauthorized: (res)->
    res.statusCode = 401
    res.end('Unauthorized')
  @remoteAuth: (req, res, next)->
    unless Config.remoteAuthUrl
      Secure.unauthorized res
    else
      request.get uri: Config.remoteAuthUrl, json: true, qs: { username: req.user.username, password: req.user.password, fileId: req.params.fileId }, (err, response, json)->
        if err
          console.error "Error in remote authorization"
          console.error err
          Secure.unauthorized res
        else if response.statusCode is 200 and json and (!req.params.fileId or req.params.fileId in json)
          next()
        else
          Secure.unauthorized res
  @apiUrl: (url)->
    if url
      @secureUrl url, 'api', Config.apiKey
    else
      @apiUrl(Config.serverUrl())
  @systemUrl: (url)->
    if url
      @secureUrl url, 'system', Config.systemKey
    else
      @systemUrl(Config.serverUrl())
  @secureUrl: (url, username, password)->
    url.replace /:\/\//, "://#{username}:#{password}@"

module.exports = Secure
