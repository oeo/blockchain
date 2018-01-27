_ = require('wegweg')({
  globals: on
})

Websocket = require 'ws'

Block = require './block'
blockchain = require './blockchain'

peers = {
  sockets: []
  server: (http_server = require('http').createServer())
}

peers.MESSAGES = MESSAGES = {
  QUERY_LAST: 0
  QUERY_ALL: 1
  RESPONSE_BLOCKS: 2
}

# message fns
peers.send = ((socket,msg) ->
  log 'Sending a message to a peer', msg
  return socket.send(JSON.stringify(msg))
)
peers.send_last_block = ((socket) ->
  log 'peers.send_last_block()'

  await blockchain.get_last_block defer e,block
  if e then throw e

  return @send(socket,{
    type: MESSAGES.RESPONSE_BLOCKS
    data: [block]
  })
)
peers.send_all_blocks = ((socket) ->
  log 'peers.send_all_blocks()'

  await blockchain.get_blockchain defer e,chain
  if e then throw e

  return @send(socket,{
    type: MESSAGES.RESPONSE_BLOCKS
    data: chain
  })
)
peers.broadcast = ((msg) ->
  for socket in peers.sockets
    socket.send(JSON.stringify(msg))
)
peers.broadcast_last_block = (->
  log 'peers.broadcast_last_block()'

  await blockchain.get_last_block defer e,block
  if e then throw e

  return @broadcast({
    type: MESSAGES.RESPONSE_BLOCKS
    data: [block]
  })
)
peers.broadcast_all_blocks = (->
  log 'peers.broadcast_all_blocks()'

  await blockchain.get_blockchain defer e,chain
  if e then throw e

  return @broadcast({
    type: MESSAGES.RESPONSE_BLOCKS
    data: chain
  })
)

# event handlers
peers.handlers = handlers = {

  connections: ((socket,req) ->
    log 'Handling connection'
    peers.sockets.push(socket)

    # bind handlers
    @errors(socket)
    @messages(socket)

    # ask peer for the latest block
    peers.send(socket,{
      type: MESSAGES.QUERY_LAST
    })
  )

  messages: ((socket) ->
    socket.on 'message', ((msg) ->
      try
        msg = JSON.parse(msg)
      catch e
        return false

      return false if !msg?.type?
      return false if msg.type !in _.vals(MESSAGES)

      #
      # MESSAGE HANDLERS
      #
      switch msg.type

        # QUERY_LAST:
        # return the block height and the last block
        when MESSAGES.QUERY_LAST
          peers.broadcast_last_block()

        # QUERY_ALL:
        # return the entire blockchain on this node
        when MESSAGES.QUERY_ALL
          #peers.broadcast_all_blocks()
          peers.send_all_blocks(socket)

        # RESPONSE_BLOCKS:
        # this is a response filled with blockchain data
        when MESSAGES.RESPONSE_BLOCKS
          handlers.incoming_blocks(msg.data)

      # trickle
      return false
    )
  )

  errors: ((socket) ->
    _close = ((x) ->
      log 'Websocket client disconnected'

      peers.sockets.splice(peers.sockets.indexOf(x),1)
    )

    socket.on 'close', -> _close(socket)
    socket.on 'error', -> _close(socket)
  )

  # sync blockchain
  incoming_blocks: ((incoming_blocks) ->
    log 'Handling incoming blocks from a peer', incoming_blocks.length

    first_incoming_block = _.first(incoming_blocks)
    last_incoming_block = _.last(incoming_blocks)

    await blockchain.get_last_block defer e,last_existing_block
    if e then throw e

    if last_existing_block.hash is last_incoming_block.hash
      log 'We are current with the incoming chain data', last_existing_block
      return false

    # we're behind by a single block
    if last_incoming_block.prev is last_existing_block.hash
      log 'Adding a new block to chain from a peer', last_incoming_block

      await blockchain.add_block last_incoming_block, defer e,block
      if e then throw e

    # we're behind by multiple blocks
    else

      # response only contained a single block, ask for the entire chain
      if incoming_blocks?.length is 1
        peers.broadcast({type:MESSAGES.QUERY_ALL})

      # response contained multiple blocks, replace our chain
      else
        await blockchain.replace_chain incoming_blocks, defer e
        if e then throw e
  )

}

# create server
peers.ws = new Websocket.Server({server:http_server})
peers.ws.on 'connection', (socket...) -> handlers.connections(socket...)

# connect to a peer
peers.connect = ((ip) ->
  log 'peers.connect()', ip
  peer_ws = new Websocket("ws://#{ip}")

  peer_ws.on 'open', -> handlers.connections(peer_ws)
  peer_ws.on 'error', -> null
)

##
module.exports = peers

