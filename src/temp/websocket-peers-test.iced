_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

ws = new Websocket('ws://localhost:11001')

ws.on 'open', ->
  log /websocket open/

ws.on 'message', (msg) ->
  log /websocket message/
  log msg

ws.on 'error', ->
  log /websocket error/

