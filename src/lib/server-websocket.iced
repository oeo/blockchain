_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

blockchain = require './blockchain'

app = _.app(bare:true)

##
p2p = {
  sockets: []
  server: require('http').createServer(app)
}

p2p.websocket = new Websocket.Server({server:p2p.server})

p2p.websocket.on 'connection', ((socket) ->
  ws
)

##
module.exports = p2p

