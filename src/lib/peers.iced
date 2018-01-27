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

peers.broadcast = ((msg) ->
  log 'Broadcasting message to peers', {peers:(peers.sockets?.length ? 0),msg:msg}
  return socket.send(JSON.stringify(msg)) for socket in peers.sockets
)

peers.broadcast_last_block = (->
  log 'Broadcasting latest block to the network'

  await blockchain.get_last_block defer e,block
  if e then throw e

  return @broadcast({
    type: MESSAGES.RESPONSE_BLOCKS
    data: [block]
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
      log 'Handling message', msg
      msg = JSON.parse(msg)

      return null if !msg?.type?
      return null if msg.type !in _.vals(MESSAGES)

      #
      # MESSAGE HANDLERS
      #
      switch msg.type

        # QUERY_LAST:
        # return the block height and the last block
        when MESSAGES.QUERY_LAST
          log /QUERY_LAST/
          await blockchain.get_last_block defer e,block
          if e then throw e

          return peers.send(socket,{
            type: MESSAGES.RESPONSE_BLOCKS
            data: [block]
          })

        # QUERY_ALL:
        # return the entire blockchain on this node
        when MESSAGES.QUERY_ALL
          log /QUERY_ALL/
          await blockchain.get_blockchain defer e,blocks
          if e then throw e

          return peers.send(socket,{
            type: MESSAGES.RESPONSE_BLOCKS
            data: blocks
          })

        # RESPONSE_BLOCKS:
        # this is a response filled with blockchain data
        when MESSAGES.RESPONSE_BLOCKS
          log /RESPONSE_BLOCKS/
          return handlers.incoming_blocks(msg.data)

      # trickle
      return false
    )
  )

  errors: ((socket) ->
    _close = ((x) ->
      log 'Websocket client closed'
      peers.sockets.splice(peers.sockets.indexOf(x),1)
    )

    socket.on 'close', -> _close(socket)
    socket.on 'error', -> _close(socket)
  )

  # sync blockchain
  incoming_blocks: ((incoming_blocks) ->
    log /incoming_blocks_type/, (typeof incoming_blocks)

    log 'Handling incoming blocks from a peer', incoming_blocks.length

    last_incoming_block = _.last(incoming_blocks)

    log /last_incoming_block/, last_incoming_block

    await blockchain.get_last_block defer e,last_existing_block
    if e then throw e

    if last_existing_block.index >= last_incoming_block.index
      log 'We are current with the incoming chain data', last_existing_block
      return false

    log 'Incoming chain is longer', last_existing_block, last_incoming_block

    # we're behind by a single block
    if last_incoming_block.prev_hash is last_existing_block.hash
      log 'Adding a new block to chain from a peer', last_incoming_block

      await blockchain.add_block last_incoming_block, defer e,block
      if e then throw e

      # broadcast latest
      return peers.broadcast({
        type: MESSAGES.RESPONSE_BLOCKS
        data: [block]
      })

    # we're behind by multiple blocks
    else

      # response only contained a single block, ask for the entire chain
      if incoming_blocks?.length is 1
        return peers.broadcast({
          type: MESSAGES.QUERY_ALL
        })

      # response contained multiple blocks, replace our chain
      else
        log 'Replacing our outdated chain with incoming one', incoming_blocks.length

        await blockchain.replace_chain incoming_blocks, defer e
        if e then throw e

        # broadcast latest
        return peers.broadcast({
          type: MESSAGES.RESPONSE_BLOCKS
          data: [_.last(incoming_blocks)]
        })

    return false
  )

}

# create server
peers.ws = new Websocket.Server({server:http_server})
peers.ws.on 'connection', (socket...) -> handlers.connections(socket...)

# connect to a peer
peers.connect = ((ip) ->
  log 'Connecting to a peer', ip
  peer_ws = new Websocket("ws://#{ip}")

  peer_ws.on 'open', -> handlers.connections(peer_ws)
  peer_ws.on 'error', -> null
)

##
module.exports = peers

