_ = require('wegweg')({
  globals: on
})

MESSAGES = {
  QUERY_LAST: 0
  QUERY_ALL: 1
  BLOCKCHAIN_RESPONSE: 2
}

Websocket = require 'ws'

ws = new Websocket('ws://localhost:11001')

send = ((ws,obj) ->
  log /sending message/, obj
  ws.send JSON.stringify(obj)
)

ws.on 'open', ->
  send(ws,{
    type: MESSAGES.QUERY_LAST
  })

ws.on 'message', (msg) ->
  log /websocket message/
  log msg

ws.on 'close', ->
  log /websocket closed/

ws.on 'error', ->
  log /websocket error/

