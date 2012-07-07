express = require 'express'
request = require 'request'
Config = require './config'
utils = require('express').utils

class Secure
  @user: (req)->
    unless req.user
      if req.headers.authorization
        credentials = new Buffer(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')
        req.user = { username: credentials[0], password: credentials[1] }
      else if req.param('auth')
        credentials = new Buffer(req.param('auth'), 'base64').toString().split(':')
        req.user = { username: credentials[0], password: credentials[1] }
    req.user
  @system: (req, res, next)->
    authorized =
      system: Config.systemKey
    Secure.authorize req, res, next, authorized, false
  @app: (req, res, next)->
    authorized =
      system: Config.systemKey
      app: Config.appKey
    Secure.authorize req, res, next, authorized, false
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
  @authorize: (req, res, next, authorized, remoteAuth = true)->
    user = @user(req)
    if req.locals.file and req.locals.file.get('public')
      return next()
    else if user && @checkCreds user.username, user.password, authorized
      return next()
    else if remoteAuth
      return @remoteAuth req, res, next
    @unauthorized(res)
  @checkCreds: (username, password, creds)->
    for key, value of creds
      return true if username is key and password is value
    return false
  @unauthorized: (res)->
    res.statusCode = 403
    res.end('Unauthorized')
  @remoteAuth: (req, res, next)->
    unless Config.remoteAuthUrl
      Secure.unauthorized res
    else
      user = @user(req) || {}
      request.get uri: Config.remoteAuthUrl, json: true, qs: { username: user.username, password: user.password, fileId: req.params.fileId }, (err, response, json)->
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
    token = new Buffer("#{username}:#{password}").toString('base64')
    unless url.match 'http://'
      url = Config.serverUrl() + url
    url.replace /:\/\/([^\/]+)\//, "://$1/secure/#{token}/"

module.exports = Secure
