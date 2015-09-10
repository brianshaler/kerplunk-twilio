React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content admin-panel'
    ,
      DOM.h1 null, 'Twilio Configuration'
      DOM.p null,
        DOM.form
          method: 'post'
          action: '/admin/twilio/setup/app'
        ,
          DOM.table null,
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Account SID:'
              DOM.td null,
                DOM.input
                  name: 'settings[twilio][accountSid]'
                  defaultValue: @props.settings?.twilio?.accountSid
                , ''
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Auth Token:'
              DOM.td null,
                DOM.input
                  name: 'settings[twilio][authToken]'
                  defaultValue: @props.settings?.twilio?.authToken
                , ''
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Twilio Number:'
              DOM.td null,
                DOM.input
                  name: 'settings[twilio][twilioNumber]'
                  defaultValue: @props.settings?.twilio?.twilioNumber
                , ''
            DOM.tr null,
              DOM.td null,
                DOM.strong null, 'Cell Number: (for notifications from twilio)'
              DOM.td null,
                DOM.input
                  name: 'settings[twilio][cellNumber]'
                  defaultValue: @props.settings?.twilio?.cellNumber
                , ''
            DOM.tr null,
              DOM.td null, ''
              DOM.td null,
                DOM.input
                  type: 'submit'
                  value: 'Save'
                , ''
