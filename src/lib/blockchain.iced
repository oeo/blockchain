if !module.parent
  global.CONFIG = (require('dotenv').config({
    path: __dirname + '/../../config'
  })).parsed

_ = require('wegweg')({
  globals: on
})

Block = require './block'

hash = require './hash'

GENESIS = new Block({
  index: 0
  ctime: 1517012327

  hash: hash.sha256(env.GENESIS_HASH_STRING)
  prev_hash: null

  data: []
})

blockchain = {
  blocks: [GENESIS]
}

## @todo: redis persistence
blockchain.get_blockchain = ((cb) ->
  return cb null, @blocks
)

blockchain.set_blockchain = ((chain,cb) ->
  @blocks = chain
  return cb null, true
)

blockchain.get_block = ((index_or_hash,cb) ->
  if !(block = _.find(@blocks,{index:(+index_or_hash)}))
    block = _.find(@blocks,{hash:index_or_hash})

  return cb null, block
)

blockchain.get_last_block = ((cb) ->
  return cb null, _.last(@blocks)
)

blockchain.add_block = ((block,cb) ->
  await @is_valid_next_block block, null, defer e,valid
  if e then return cb e

  if !valid
    return cb new Error 'Block is invalid'

  @blocks.push(new_block = new Block(block))

  return cb null, new_block
)

##
blockchain.is_valid_next_block = ((block,prev_block,cb) ->
  if !Block.is_valid_structure(block)
    log new Error 'Invalid block structure'
    return cb null, false

  if !prev_block
    await @get_last_block defer e,last
    if e then return cb e

  if block.index isnt (last.index + 1)
    log new Error 'Invalid block ID'
    return cb null, false

  if block.prev_hash isnt last.hash
    log new Error 'Invalid previous block hash'
    return cb null, false

  if block.hash isnt Block.calculate_hash(block)
    log new Error 'Invalid block hash'
    return cb null, false

  return cb null, true
)

blockchain.is_valid_chain = ((chain,cb) ->
  chain_genesis = chain.shift()

  if chain_genesis.hash isnt GENESIS_BLOCK.hash
    log new Error 'Invalid genesis block'
    return false

  i = 1

  for block in chain
    prev_block = block[i - 1]

    await @is_valid_next_block block, prev_block, defer e,valid
    if e then return cb e

    if !valid
      log new Error 'Invalid block in chain', block.index
      return false

    i += 1

  return cb null, true
)

blockchain.generate_next_block = ((data,cb) ->
  await @get_last_block defer e,last
  if e then return cb e

  block = new Block({
    index: (last.index + 1)
    ctime: _.time()
    prev_hash: last.hash
    data: data
  })

  return cb null, block
)

blockchain.replace_chain = ((new_chain,cb) ->
  await @get_blockchain defer e,cur_chain
  if e then return cb e

  if new_chain.length > cur_chain.length
    await @is_valid_chain new_chain, defer e,valid
    if e then return cb e

    if valid
      log 'Received blockchain is valid and longer than existing chain, replacing our chain'

  return cb null, true
)

##
module.exports = blockchain

## test
if !module.parent
  log /TEST/

  await blockchain.generate_next_block 'Hello', defer e,next_block
  if e then throw e

  log /next_block/, next_block

  exit 0

