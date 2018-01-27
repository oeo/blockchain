_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

blockchain = require './blockchain'

app = _.app(bare:true)

websocket = {
  server: (new Websocket.Server({port:env.WEBSOCKET_PORT}))
  sockets: []
}

##
module.exports = websocket

