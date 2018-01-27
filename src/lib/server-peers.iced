_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

blockchain = require './blockchain'

# primary export
peers = {
  server: (http_server = require('http').createServer())
  sockets: []
}

# send to all peers
peers.broadcast = ((msg) ->
  log 'Broadcasting message', {peers:(peers.sockets?.length ? 0),msg:msg}
  socket.send(JSON.stringify(msg)) for socket in peers.sockets
  return true
)

# event handlers
peers.handlers = handlers = {
  connections: ((socket,req) ->
    log 'Handling connection', req.connection.remoteAddress
    peers.sockets.push(socket)

    # bind handlers
    @errors(socket)
    @messages(socket)

    peers.broadcast 'aye lmaoooo'
  )

  messages: ((socket) ->
    socket.on 'message', ((msg) ->
      log 'Handling message', msg
      msg = JSON.parse(msg)
    )
  )

  errors: ((socket) ->
    _close = ((me) ->
      log 'Websocket client closed', s
      peers.sockets.splice(peers.sockets.indexOf(me),1)
    )

    socket.on 'close', -> _close(socket)
    socket.on 'error', -> _close(socket)
  )
}

# @todo: subs

# create server
peers.ws = new Websocket.Server({server:http_server})
peers.ws.on 'connection', (socket...) -> handlers.connections(socket...)

##
module.exports = peers

