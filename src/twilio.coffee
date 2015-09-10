_ = require 'lodash'
Promise = require 'when'

twilio = require 'twilio'

module.exports = (System) ->
  client = null

  getClient = (next) ->
    return next null, client if client
    System.getSettings (err, settings) ->
      return next err if err
      unless settings?.accountSid and settings.authToken and settings.twilioNumber
        return next new Error 'no credentials'
      client = twilio settings.accountSid, settings.authToken
      next null, client, settings.twilioNumber, settings.cellNumber

  preSendSms = (obj) ->
    console.log 'preSendSms', obj
    return obj unless obj.notify
    deferred = Promise.defer()
    getClient (err, client, twilioNumber, cellNumber) ->
      return deferred.reject err if err
      obj.recipient = cellNumber
      obj.sender = twilioNumber
      deferred.resolve obj
    deferred.promise

  sendSms = (obj) ->
    console.log 'sms.send', obj
    # return obj
    deferred = Promise.defer()
    getClient (err, client, twilioNumber, cellNumber) ->
      return deferred.reject err if err
      client.messages.create
        to: obj.recipient ? cellNumber
        from: obj.sender ? twilioNumber
        body: obj.message
      , (err, message) ->
        console.log 'err', err if err
        return deferred.reject err if err
        obj.twilioMessage = message
        deferred.resolve obj
    deferred.promise

  send = (req, res, next) ->
    getClient (err, client, twilioNumber, cellNumber) ->
      return next err if err
      client.messages.create
        to: req.query?.recipient ? req.body?.recipient ? cellNumber
        from: twilioNumber
        body: req.query?.message ? req.body?.message ? 'sup'
      , (err, message) ->
        return next err if err
        console.log 'message', message?.sid ? message
        res.send
          message: message

  receive = (req, res, next) ->
    res.header 'Cache-Control', 'no-cache, no-store, must-revalidate'
    res.header 'Pragma', 'no-cache'

    obj =
      ya: 'cool' + Math.floor Math.random() * 100
      body: req.body
    obj = _.extend {}, req.body
    obj.message = obj.Body
    obj.responseMessage = null
    console.log 'received', obj
    System.do 'sms.receive', obj
    .then (obj) ->
      twiml = new twilio.TwimlResponse()
      if obj.responseMessage
        twiml.message obj.responseMessage
      res.send twiml
      obj

  setup = (req, res, next) ->
    System.getSettings (err, settings) ->
      return next err if err
      console.log 'setup', req.body
      if req.body?.settings?.twilio?.accountSid
        settings = _.merge settings, req.body.settings.twilio
        client = null
        System.updateSettings settings, (err) ->
          return next err if err
          res.render 'app',
            settings:
              twilio: settings
        return
      res.render 'app',
        settings:
          twilio: settings

  globals:
    public:
      nav:
        Admin:
          Settings:
            Twilio:
              Configure: '/admin/twilio/setup/app'

  events:
    sms:
      receive:
        do: (obj) -> obj
      send:
        pre: preSendSms
        do: sendSms

  routes:
    admin:
      '/admin/twilio/send': 'send'
      '/admin/twilio/setup/:step': 'setup'
      '/admin/twilio': 'index'
    public:
      '/message/incoming': 'receive'

  handlers:
    setup: setup
    send: send
    index: (req, res) -> res.redirect '/admin/twilio/setup/app'
    receive: receive
